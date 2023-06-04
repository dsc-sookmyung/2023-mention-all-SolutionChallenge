package com.example.cpr2u_android.presentation.call

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.BottomSheetMapBinding
import com.example.cpr2u_android.domain.model.CallInfoBottomSheet
import com.google.android.gms.maps.model.LatLng
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.Timer
import java.util.TimerTask
import kotlin.properties.Delegates

class CallInfoBottomSheetDialog(val item: CallInfoBottomSheet, val convertTime: String, private val checkDistanceAndShowLog: () -> Unit) :
    BottomSheetDialogFragment() {
    private lateinit var binding: BottomSheetMapBinding
    private val callViewModel: CallViewModel by sharedViewModel()

    private var timerSec: Int = 0
    private var time: TimerTask? = null
    private var timerText: TextView? = null
    private val handler: Handler = Handler()
    private var callId by Delegates.notNull<Int>()
    private lateinit var updater: Runnable
    var isDispatch = true

    private val simpleDateTypeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.KOREA)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(STYLE_NORMAL, R.style.BottomSheetDialog)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        binding =
            BottomSheetMapBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        binding.apply {
            mapInfo = item
            startTime = convertTime
            clMarkerInfo.visibility = View.VISIBLE
            clTimer.visibility = View.INVISIBLE
            tvReport.visibility = View.INVISIBLE
            tvDispatch.setOnClickListener {
                // 기본 dialog
                AlertDialog.Builder(requireContext())
                    .setTitle("Shall we start out?")
                    .setMessage("If you arrive within 5 minutes,\nthe patient's survival rate increases.")
                    .setNegativeButton(
                        "cancel",
                    ) { _, _ -> dismiss() }
                    .setPositiveButton(
                        "ok",
                    ) { _, _ ->
                        if (isDispatch) {
                            isCancelable = false
                            // 출동하기 성공시 dismiss
                            callViewModel.postDispatch(item.callId)
                            isDispatch = false
                            callViewModel.dispatchSuccess.observe(viewLifecycleOwner) {
                                if (it) {
                                    Timber.d("it , dismiss ->$it")
                                    tvDispatch.visibility = View.GONE
                                    clMarkerInfo.visibility = View.INVISIBLE
                                    clTimer.visibility = View.VISIBLE
                                    tvReport.visibility = View.VISIBLE
                                    tvDispatch.text = "ARRIVED"
                                    // 타이머 시작
                                    timerText = binding.tvMinute
                                    val targetTime = item.callAt
                                    val difference = calculateTimeDifference(targetTime)
                                    val (minutes, seconds) = difference
                                    timerSec = minutes * 60 + seconds
                                    time = object : TimerTask() {
                                        override fun run() {
                                            checkDistanceAndShowLog()
                                            callViewModel.isDispatch.postValue(true)
                                            updateTime()
                                            if (timerSec >= 900) {
                                                callViewModel.isDispatch.postValue(false)
                                                return
                                            }
                                            timerSec++
                                        }
                                    }
                                    val timer = Timer()
                                    timer.schedule(time, 0, 1000)
                                } else {
                                    Timber.d("it -> $it")
                                }
                            }
                        } else {
                            isCancelable = true
                            // 출동종료
                            callViewModel.postDispatchArrive()
                            callViewModel.dispatchArriveSuccess.observe(viewLifecycleOwner) {
                                if (it) {
                                    dismiss()
                                } else {
                                    Timber.d("arrive server fail")
                                }
                            }
                        }
                    }
                    .show()
            }
            tvReport.setOnClickListener {
                Timber.d("callViewmodel id -> ${callViewModel.dispatchId.value}")

                val bundle = Bundle().apply {
                    putInt("dispatchId", callViewModel.dispatchId.value!!)
                }
                startActivity(
                    Intent(
                        requireContext(),
                        DispatchReportActivity::class.java,
                    ).putExtras(bundle),
                )
            }
        }
    }

    private fun calculateTimeDifference(targetTime: String): Pair<Int, Int> {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        val currentTime = System.currentTimeMillis()
        val targetDateTime = dateFormat.parse(targetTime)?.time ?: 0
        val timeDifference = currentTime - targetDateTime

        val minutes = (timeDifference / (1000 * 60)).toInt()
        val seconds = ((timeDifference / 1000) % 60).toInt()

        return Pair(minutes, seconds)
    }

    private fun updateTime() {
        updater = Runnable {
            val minute = if (timerSec / 60 < 1) "00" else "0${(timerSec / 60)}"
            val second =
                if (timerSec % 60 < 10) "0${(timerSec % 60)}" else (timerSec % 60).toString()
            binding.tvMinute.setText("$minute : $second")
        }
        handler.post(updater)
    }
}
