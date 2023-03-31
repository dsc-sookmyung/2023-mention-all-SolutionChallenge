package com.example.cpr2u_android.presentation.call

import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.widget.TextView
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivityCallingBinding
import com.example.cpr2u_android.presentation.base.BaseActivity
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.util.*
import kotlin.properties.Delegates

class CallingActivity : BaseActivity<ActivityCallingBinding>(R.layout.activity_calling) {
    private val callViewModel: CallViewModel by viewModel()

    private var timerSec: Int = 0
    private var time: TimerTask? = null
    private var timerText: TextView? = null
    private val handler: Handler = Handler()
    private var callId by Delegates.notNull<Int>()
    private lateinit var updater: Runnable
    var ring = MediaPlayer()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Timber.d("####2 oncreate...")
        callId = intent.getIntExtra("callId", -1)
        Timber.d("call id GET -> $callId")
        binding.tvSituationEnd.setOnClickListener {
            callViewModel.postCallEnd(callId)
            callViewModel.callEndSuccess.observe(this) {
                if (it) {
                    Timber.d("#### call end success observe success")
                    handler.removeCallbacks(updater)
                    Timber.d("#### finish 직전")
                    finish()
                    Timber.d("#### finish 뒤..")
                } else {
                    Timber.d("#### 에엥...")
                }
            }
//            callViewModel.callEndUIState.flowWithLifecycle(lifecycle).onEach {
//                when (it) {
//                    is UiState.Success -> {
//                        Timber.d("success")
//                        handler.removeCallbacks(updater)
//                        finish()
//                    }
//                    is UiState.Loading -> {
//                        Timber.d("Loading..")
//                    }
//                    else -> {
//                        Timber.d("fail...")
//                    }
//                }
//            }
        }

        timerText = binding.tvMinute
        timerSec = 0
        time = object : TimerTask() {
            override fun run() {
                updateTime()
                if (timerSec >= 300) return
                if (timerSec % 15 == 0) {
                    // TODO : 15초마다 서버 통신
                }
                timerSec++
            }
        }
        val timer = Timer()
        timer.schedule(time, 0, 1000)

        ring = MediaPlayer.create(this@CallingActivity, com.example.cpr2u_android.R.raw.midi)
        ring.start()
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

    override fun onBackPressed() {
//        super.onBackPressed()
    }

    override fun onStop() {
        super.onStop()
        ring.stop()
    }
}
