package com.example.cpr2u_android.presentation.education

import android.Manifest
import android.app.AlertDialog
import android.app.Dialog
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.graphics.PointF
import android.hardware.Camera
import android.media.MediaPlayer
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.util.Log
import android.view.SurfaceView
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.DialogFragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentPosePractice2Binding
import com.example.cpr2u_android.ml.camera.CameraSource
import com.example.cpr2u_android.ml.data.BodyPart
import com.example.cpr2u_android.ml.data.Device
import com.example.cpr2u_android.ml.data.Person
import com.example.cpr2u_android.ml.ml.ModelType
import com.example.cpr2u_android.ml.ml.MoveNet
import com.example.cpr2u_android.presentation.base.BaseFragment
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber
import java.util.Timer
import java.util.TimerTask
import kotlin.math.abs

class PosePractice2Fragment :
    BaseFragment<FragmentPosePractice2Binding>(R.layout.fragment_pose_practice_2) {
    private val educationViewModel: EducationViewModel by sharedViewModel()

    companion object {
        private const val FRAGMENT_DIALOG = "dialog"
    }

    private lateinit var surfaceView: SurfaceView
    private var modelPos = 1 // 1 == MoveNet Thunder model
    private var device = Device.CPU
    private lateinit var tvScore: TextView
    private var cameraSource: CameraSource? = null

    /**
     * CPR 자세 인식에 필요한 변수들
     */
    private var maxHeight = 0f
    private var minHeight = 0f
    private var beforeWrist = 0f
    private var increased = true
    private var wristList = arrayListOf<Float>()

    var pressCount: Int = 0
    private var avgMaxHeight = 0f
    private var avgMinHeight = 0f
    private var avgDepth = 0f

    var correctAngle: Int = 0
    var incorrectAngle: Int = 0
    var compressionRate: Int = 0
    var pressDepth: Int = 0

    private var countDownTimer: CountDownTimer? = null
    private var timeLeftInMillis = 0L
    private lateinit var foundPerson: Person
    private var timerEnd = false
    var isPreparing = false
    var isTimerRunning = true
    var timeFinished = false

    var ring = MediaPlayer()

    private val TAG = "CPR2U"

    private val requestPermissionLauncher =
        registerForActivityResult(
            ActivityResultContracts.RequestPermission(),
        ) { isGranted: Boolean ->
            if (isGranted) {
                // Permission is granted. Continue the action or workflow in your app.
            } else {
                // Explain to the user that the feature is unavailable because the
                // features requires a permission that the user has denied. At the
                // same time, respect the user's decision. Don't link to system
                // settings in an effort to convince the user to change their
                // decision.
//                ErrorDialog.newInstance(getString(R.string.tfe_pe_request_permission))
//                    .show(supportFragmentManager, FRAGMENT_DIALOG)
            }
        }
    val timer = Timer()
    private var timerSec: Int = 0
    private var time: TimerTask? = null
    private var timerText: TextView? = null
    private val handler: Handler = Handler()
    private var updater: Runnable? = null
    private var showView = false
    private var goneView = false

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE

        val camera = Camera.CameraInfo.CAMERA_FACING_FRONT
        // keep screen on while app is running
        activity?.window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        tvScore = view.findViewById(R.id.tvScore)
        surfaceView = view.findViewById(R.id.surfaceView)
        surfaceView.display
        binding.ivCprGuidelines.visibility = View.VISIBLE
        binding.view3Seconds.visibility = View.VISIBLE
        binding.tvReady3Seconds.visibility = View.VISIBLE
        binding.cl3Seconds.visibility = View.GONE

        timerText = binding.tvTimer
        timerSec = 0

        binding.tvQuit.setOnClickListener {
            countDownTimer?.cancel()
//            handler.removeCallbacks(updater)
            activity?.finish()
        }
    }

    private fun calculateTime() {
        time = object : TimerTask() {
            override fun run() {
                updateTime()
                // TODO : 추후 2분으로 수정 필요
                if (timerSec >= 120) {
                    educationViewModel.armAngle = calculateArmAngle()
                    educationViewModel.compressionRate = calculateCompressionRate()
                    educationViewModel.pressDepth = calculatePressDepth()
                    educationViewModel.postPracticeScore =
                        educationViewModel.armAngle.score + educationViewModel.compressionRate.score + educationViewModel.pressDepth.score
                    timer.cancel()
                    activity?.runOnUiThread {
                        findNavController().navigate(R.id.action_posePractice2Fragment_to_posePractice3Fragment)
                    }
                }
                timerSec++
            }
        }
        timer.schedule(time, 0, 1000)
    }

    private fun updateTime() {
        updater = Runnable {
            Timber.d("##### TimerSec = $timerSec")
            val minute = if (timerSec / 60 < 1) "00" else "0${(timerSec / 60)}"
            val second =
                if (timerSec % 60 < 10) "0${(timerSec % 60)}" else (timerSec % 60).toString()
            timerText?.text = "$minute : $second"
        }
        updater?.let { handler.post(it) }
    }

    override fun onStart() {
        super.onStart()
        requestPermission()
    }

    override fun onResume() {
        Timber.d("onResume...")
        cameraSource?.resume()
        countDownTimer?.cancel()
        super.onResume()
    }

    override fun onPause() {
        Timber.d("onPause...")
        cameraSource?.close()
        cameraSource = null
        countDownTimer?.cancel()
        timer.cancel()
        updater?.let {
            handler.removeCallbacks(it)
            updater = null
        }
        super.onPause()
    }

    override fun onDestroy() {
        Timber.d("onDestroy...")
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    // check if permission is granted or not.
    private fun isCameraPermissionGranted(): Boolean {
        return ContextCompat.checkSelfPermission(
            requireContext(),
            Manifest.permission.CAMERA,
        ) == PackageManager.PERMISSION_GRANTED
    }

    // open camera
    private fun openCamera() {
        if (isCameraPermissionGranted()) {
            if (cameraSource == null) {
                cameraSource =
                    CameraSource(
                        surfaceView,
                        object : CameraSource.CameraSourceListener {
                            override fun onFPSListener(fps: Int) {
//                                tvFPS.text = getString(R.string.tfe_pe_tv_fps, fps)
                            }

                            override fun onDetectedInfo(
                                personScore: Float?,
                                poseLabels: List<Pair<String, Float>>?,
                                persons: List<Person>,
                            ) {
                                // tvScore: 자세 인식 모델의 정확도 점수
                                tvScore.text =
                                    getString(R.string.tfe_pe_tv_score, personScore ?: 0f)
                                /**
                                 * TODO: 여기서부터 CPR 자세 인식 코드 시작
                                 * persons에 더 많은 person 데이터가 있을 수록 정확도가 높아진다.
                                 * persons의 0번째에 있는 데이터를 가져와 자세를 분석한다.
                                 */
                                // TODO : CPR 처음 자세 올바른지 판단 후 시작
//                                if(isCorrectPosture(persons[0])) {
                                measureIsPreparing(persons[0])
                                if (isPreparing) {
                                    Timber.d("########## 여기")
                                    isPreparing = false
                                    if (isTimerRunning) {
                                        isTimerRunning = false
                                        set3secondsView()
                                        if (showView) {
                                            activity?.runOnUiThread {
                                                ring = MediaPlayer.create(
                                                    requireContext(),
                                                    com.example.cpr2u_android.R.raw.cpr_posture_sound,
                                                )
                                                ring.start()
                                                var timeLeft = 4
                                                countDownTimer =
                                                    object : CountDownTimer(3000, 1000) {
                                                        override fun onTick(millisUntilFinished: Long) {
                                                            timeLeft--
                                                            binding.tv3SecondsNum.text =
                                                                timeLeft.toString()
                                                        }

                                                        override fun onFinish() {
                                                            set3secondsViewGone()
                                                            timerSec = 0
                                                            timeFinished = true
                                                            calculateTime()
                                                        }
                                                    }.start()
                                            }
                                        }
                                    }
                                }
                                if (timeFinished) {
                                    measureCprScore(persons[0])
                                }
                            }
                        },
                    ).apply {
                        prepareCamera()
                    }
                lifecycleScope.launch(Dispatchers.Main) {
                    cameraSource?.initCamera()
                }
            }
            createPoseEstimator()
        } else {
            requestPermission()
        }
    }

    private fun set3secondsView() {
        Timber.d("#### 저기요...")
        activity?.runOnUiThread {
            binding.ivCprGuidelines.visibility = View.GONE
            binding.view3Seconds.visibility = View.GONE
            binding.tvReady3Seconds.visibility = View.GONE
            binding.cl3Seconds.visibility = View.VISIBLE
        }
        showView = true
    }

    private fun set3secondsViewGone() {
        Timber.d("??? 들어오니???")
        activity?.runOnUiThread {
            Timber.d("???>> 들어오니???")
            binding.cl3Seconds.visibility = View.GONE
        }
        goneView = true
    }

    private fun measureIsPreparing(person: Person): Boolean {
        lateinit var shoulderLeft: PointF
        lateinit var shoulderRight: PointF

        lateinit var elbowLeft: PointF
        lateinit var elbowRight: PointF

        lateinit var wristLeft: PointF
        lateinit var wristRight: PointF

        lateinit var hipLeft: PointF
        lateinit var hipRight: PointF

        lateinit var kneeLeft: PointF
        lateinit var kneeRight: PointF

        lateinit var ankleLeft: PointF
        lateinit var ankleRight: PointF

        person.keyPoints.forEach { point ->
            when (point.bodyPart) {
                BodyPart.LEFT_SHOULDER -> {
                    shoulderLeft = point.coordinate
                }

                BodyPart.RIGHT_SHOULDER -> {
                    shoulderRight = point.coordinate
                }

                BodyPart.LEFT_ELBOW -> {
                    elbowLeft = point.coordinate
                }

                BodyPart.RIGHT_ELBOW -> {
                    elbowRight = point.coordinate
                }

                BodyPart.LEFT_WRIST -> {
                    wristLeft = point.coordinate
                }

                BodyPart.RIGHT_WRIST -> {
                    wristRight = point.coordinate
                }

                BodyPart.LEFT_HIP -> {
                    hipLeft = point.coordinate
                }

                BodyPart.RIGHT_HIP -> {
                    hipRight = point.coordinate
                }

                BodyPart.LEFT_KNEE -> {
                    kneeLeft = point.coordinate
                }

                BodyPart.RIGHT_KNEE -> {
                    kneeRight = point.coordinate
                }

                BodyPart.LEFT_ANKLE -> {
                    ankleLeft = point.coordinate
                }

                BodyPart.RIGHT_ANKLE -> {
                    ankleRight = point.coordinate
                }

                else -> {}
            }
        }

        var isElbowLeftVertical =
            abs(shoulderLeft.x - elbowLeft.x) < 20 && abs(elbowLeft.x - wristLeft.x) < 20 &&
                wristLeft.y > elbowLeft.y && elbowLeft.y > shoulderLeft.y
        var isElbowRightVertical =
            abs(shoulderRight.x - elbowRight.x) < 20 && abs(elbowRight.x - wristRight.x) < 20 &&
                wristRight.y > elbowRight.y && elbowRight.y > shoulderRight.y

        var isBodyLeftVertical = shoulderLeft.x < hipLeft.x && shoulderLeft.y < hipLeft.y
        var isBodyRightVertical = shoulderRight.x < hipRight.x && shoulderRight.y < hipRight.y

        var isBodyLeftSeated =
            hipLeft.x > kneeLeft.x && kneeLeft.x < ankleLeft.x && hipLeft.x < ankleLeft.x &&
                hipLeft.y < kneeLeft.y && hipLeft.y < ankleLeft.y && abs(ankleLeft.y - kneeLeft.y) < 20
        var isBodyRightSeated =
            hipRight.x > kneeRight.x && kneeRight.x < ankleRight.x && hipRight.x < ankleRight.x &&
                hipRight.y < kneeRight.y && hipRight.y < ankleRight.y && abs(ankleRight.y - kneeRight.y) < 20

        val isElbowVertical = isElbowLeftVertical && isElbowRightVertical
        val isBodyVertical = isBodyLeftVertical && isBodyRightVertical
        val isBodySeated = isBodyLeftSeated && isBodyRightSeated

        if (isElbowVertical && isBodyVertical && isBodySeated) {
            Log.i(TAG, "CPR 준비 완료")
            isPreparing = true
            return true
        }
        return false
    }

    /**
     * CPR 자세 인식
     */
    private fun measureCprScore(person: Person) {
        var xShoulder = .0f
        var yShoulder = .0f
        var xElbow = .0f
        var yElbow = .0f
        var xWrist = .0f
        var yWrist = .0f

        // person이 갖고 있는 관절 데이터들에서 어깨, 팔꿈치, 손목 데이터 추출 (현재 임시로 왼쪽 관절만 추출한 상태)
        person.keyPoints.forEach { point ->
            when (point.bodyPart) {
                BodyPart.LEFT_SHOULDER -> {
                    xShoulder = point.coordinate.x
                    yShoulder = point.coordinate.y
                }

                BodyPart.LEFT_ELBOW -> {
                    xElbow = point.coordinate.x
                    yElbow = point.coordinate.y
                }

                BodyPart.LEFT_WRIST -> {
                    xWrist = point.coordinate.x
                    yWrist = point.coordinate.y
                }

                else -> {}
            }
        }
        measureElbowDegree(person)
        measureCprRate(person)
    }

    private fun measureElbowDegree(person: Person) {
        // person이 갖고 있는 관절 데이터들에서 어깨, 팔꿈치, 손목 데이터 추출 (현재 임시로 왼쪽 관절만 추출한 상태)
        lateinit var shoulder: PointF
        lateinit var elbow: PointF
        lateinit var wrist: PointF

        person.keyPoints.forEach { point ->
            when (point.bodyPart) {
                BodyPart.LEFT_SHOULDER -> {
                    shoulder = point.coordinate
                }

                BodyPart.LEFT_ELBOW -> {
                    elbow = point.coordinate
                }

                BodyPart.LEFT_WRIST -> {
                    wrist = point.coordinate
                }

                else -> {}
            }
        }

        var isCorrect = shoulder.x - elbow.x < 20 && elbow.x - wrist.x < 20
        if (isCorrect) {
            Log.i(TAG, "올바른 자세에요!")
            // TODO : 맞은 횟수 세기
            correctAngle++
        } else {
            Log.i(TAG, "팔을 90도로 유지하세요!")
            // TODO : 틀린 횟수 세기
            incorrectAngle++
        }
    }

    private fun measureCprRate(person: Person) {
        lateinit var wrist: PointF

        // 정확도 0.4이상인 것만 계산
        if (person.score > 0.4) {
            person.keyPoints.forEach { point ->
                when (point.bodyPart) {
                    BodyPart.LEFT_WRIST -> {
                        wrist = point.coordinate
                    }

                    else -> {}
                }
            }

            pressCount = wristList.size
            // 손목의 높이가 상승 곡선에서 꼭짓점을 찍고 하강하는 경우
            if (increased && beforeWrist > wrist.y + 1) {
                // 고점 이상값인지 검증
                avgMaxHeight = (avgMaxHeight * pressCount + wrist.y) / (pressCount + 1)
                Log.i(TAG, "고점 이상값 " + (avgMaxHeight - wrist.y).toString())
                if (Math.abs(avgMaxHeight - wrist.y) < 50) {
                    // 이상값이 아니라 판단되면 고점 등록
                    increased = false
                    maxHeight = beforeWrist
                    Log.i(TAG, "평균 " + avgMaxHeight + " 고점 " + maxHeight)
                }
            }

            // 손목의 높이가 하강 곡선에서 꼭짓점을 찍고 상승하는 경우
            else if (!increased && beforeWrist < wrist.y - 1) {
                // 저점 이상값인지 검증
                avgMinHeight = (avgMinHeight * pressCount + wrist.y) / (pressCount + 1)
                Log.i(TAG, "저점 이상값 " + (avgMinHeight - wrist.y).toString())
                if (Math.abs(avgMinHeight - wrist.y) < 50) {
                    // 이상값이 아니라 판단되면 저점 등록
                    increased = true
                    minHeight = beforeWrist
                    Log.i(TAG, "평균 " + avgMinHeight + " 저점 " + minHeight)

                    // depth 등록
                    val depth = maxHeight - minHeight
                    if (depth > 0) {
                        Log.i(TAG, "깊이 : " + depth.toString())
                        wristList.add(depth)
                    }

                    Log.e(TAG, "개수 " + wristList.size.toString())
                    Log.e(TAG, "${wristList.last()}")
                }
            }

            beforeWrist = wrist.y
            Log.e(TAG, "깊이 " + getCprDepthResult())
            Log.e(TAG, "속도 " + getCprRateResult())
        }
    }

    private fun getCprRateResult(): Double {
        pressCount = wristList.size
        val minutes = 60.0
        // per sec 기준
        return pressCount / minutes
    }

    private fun getCprDepthResult(): Float {
        pressCount = wristList.size
        var min = Float.MAX_VALUE
        var max = 0f
        var depth = 0f
        for (w in wristList) {
            if (w < min) {
                min = w
            }; else if (w > max) max = w
            depth += w
        }
        return (depth - min - max) / (pressCount - 2)
    }

    private fun calculateCompressionRate(): ResultMsg {
        return when (pressCount / 2) {
            in 100..130 -> ResultMsg(40, "adequate", "Good job! Very Adequate")
            in 80 until 100 -> ResultMsg(25, "slow", "It's slow. Press more faster")
            in 131 until 150 -> ResultMsg(25, "fast", "It's fast. Press more slower")
            in 151..999999 -> ResultMsg(10, "tooFast", "It's too fast. Press slower")
            in 0 until 80 -> ResultMsg(10, "tooSlow", "It's too slow. Press faster")
            else -> ResultMsg(0, "wrong", "Something went wrong. Try Again")
        }
    }
    // 팔 각도
    private fun calculateArmAngle(): ResultMsg {
        val total: Double = (correctAngle + incorrectAngle).toDouble()
        if (total < 100) return ResultMsg(0, "wrong", "Something went wrong.\nTry Again")
        return when (total) {
            in total * 0.7..total -> ResultMsg(40, "adequate", "Good job! Very Nice angle!")
            in total * 0.6..total * 0.7 -> ResultMsg(25, "almost", "Almost there. Try again")
            in total * 0.5..total * 0.6 -> ResultMsg(
                10,
                "notGood",
                "Pay more attention to\nthe angle of your arms",
            )
            else -> ResultMsg(0, "bad", "You need some more practice")
        }
    }

    // 압박 깊이
    private fun calculatePressDepth(): ResultMsg {
        return when (getCprDepthResult()) {
            in 18.0..30.0 -> ResultMsg(20, "adequate", "Good job! Very adequate!")
            in 5.0..18.0 -> ResultMsg(10, "shallow", "Press little deeper")
            in 30.0..100.0 -> ResultMsg(10, "deep", "Press slight")
            else -> ResultMsg(0, "wrong", "Something went wrong.\nTry Again")
        }
    }

    // 자세 추정 모델 실행 (Movenet Thunder, CPU가 적절)
    private fun createPoseEstimator() {
        // For MoveNet MultiPose, hide score and disable pose classifier as the model returns
        // multiple Person instances.
        val poseDetector = when (modelPos) {
            1 -> {
                // MoveNet Thunder (SinglePose)
                showDetectionScore(true)
                MoveNet.create(requireContext(), device, ModelType.Thunder)
            }

            else -> {
                null
            }
        }
        poseDetector?.let { detector ->
            cameraSource?.setDetector(detector)
        }
    }

    // Show/hide the detection score.
    private fun showDetectionScore(isVisible: Boolean) {
        tvScore.visibility = if (isVisible) View.VISIBLE else View.GONE
    }

    private fun requestPermission() {
        when (PackageManager.PERMISSION_GRANTED) {
            ContextCompat.checkSelfPermission(
                requireContext(),
                Manifest.permission.CAMERA,
            ),
            -> {
                // You can use the API that requires the permission.
                openCamera()
            }

            else -> {
                // You can directly ask for the permission.
                // The registered ActivityResultCallback gets the result of this request.
                requestPermissionLauncher.launch(
                    Manifest.permission.CAMERA,
                )
            }
        }
    }

    /**
     * Shows an error message dialog.
     */
    class ErrorDialog : DialogFragment() {

        override fun onCreateDialog(savedInstanceState: Bundle?): Dialog =
            AlertDialog.Builder(activity)
                .setMessage(requireArguments().getString(ARG_MESSAGE))
                .setPositiveButton(android.R.string.ok) { _, _ ->
                    // do nothing
                }
                .create()

        companion object {

            @JvmStatic
            private val ARG_MESSAGE = "message"

            @JvmStatic
            fun newInstance(message: String): ErrorDialog = ErrorDialog().apply {
                arguments = Bundle().apply { putString(ARG_MESSAGE, message) }
            }
        }
    }

    override fun onStop() {
        super.onStop()
        ring.stop()
    }
}

data class ResultMsg(val score: Int, val title: String, val desc: String)
