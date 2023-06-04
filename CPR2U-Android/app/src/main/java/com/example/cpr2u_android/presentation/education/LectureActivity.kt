package com.example.cpr2u_android.presentation.education

import android.app.Dialog
import android.opengl.Visibility
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.webkit.WebViewClient
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivityLectureBinding
import com.example.cpr2u_android.databinding.DialogQuizBinding
import com.example.cpr2u_android.presentation.base.BaseActivity
import com.example.cpr2u_android.util.UiState
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber


class LectureActivity : BaseActivity<ActivityLectureBinding>(R.layout.activity_lecture) {
    private val educationViewModel: EducationViewModel by viewModel()
    private lateinit var handler: Handler
    private lateinit var runnable: Runnable
    private var start: Long = 0
    private var end: Long = 0
    private var sum: Long = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding.webView.loadUrl("https://youtu.be/5DWyihalLMM")
        val webViewSetting = binding.webView.settings
        webViewSetting.javaScriptEnabled = true
        binding.webView.webViewClient = WebViewClient()
        handler = Handler(Looper.getMainLooper())
        runnable = Runnable {
            val dialog = Dialog(this)
            val binding = DataBindingUtil.inflate<DialogQuizBinding>(
                LayoutInflater.from(this),
                R.layout.dialog_quiz,
                null,
                false,
            )
            binding.tvTitle.text = "Lecture Complete!"
            binding.tvSubtitle.text = "You have completed the Lecture!\nYou are one step closer to becoming\na CPR Angel!"
            binding.ivHeart.visibility = View.VISIBLE
            binding.ivHeartGray.visibility = View.INVISIBLE
            binding.buttonFinish.setOnClickListener {
                educationViewModel.postLectureId()
                educationViewModel.testUIState.flowWithLifecycle(lifecycle).onEach {
                    when (it) {
                        is UiState.Success -> {
                            Timber.d("success")
                            dialog.dismiss()
                            finish()
                        }
                        is UiState.Loading -> {
                            Timber.d("로딩중...")
                        }
                        else -> {
                            Timber.d("fail -> $it")
                            Timber.d("dialog-fail")
                        }
                    }
                }.launchIn(lifecycleScope)
            }
            dialog.setContentView(binding.root)
            dialog.window?.setLayout(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
            )

            dialog.show()
        }
        handler.postDelayed(runnable, 40 * 60 * 1000)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(runnable)
    }

    override fun onBackPressed() {
        super.onBackPressed()
        handler.removeCallbacks(runnable)
    }
}
