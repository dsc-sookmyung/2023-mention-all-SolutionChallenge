package com.example.cpr2u_android.presentation.call

import android.os.Bundle
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivityDispatchReportBinding
import com.example.cpr2u_android.presentation.base.BaseActivity
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber

class DispatchReportActivity :
    BaseActivity<ActivityDispatchReportBinding>(R.layout.activity_dispatch_report) {
    val callViewModel: CallViewModel by viewModel()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val dispatchId = intent.getIntExtra("dispatchId", -1)
        Timber.d("on Create -> $dispatchId")

        binding.tvContinue.setOnClickListener {
            val content = binding.etContent.text.toString()
            callViewModel.postDispatchReport(dispatchId, content)
            callViewModel.dispatchReportSuccess.observe(this) {
                if (it) {
                    finish()
                } else {
                    Timber.d("report fail")
                }
            }
        }
    }
}
