package com.example.cpr2u_android.presentation.auth

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.core.widget.addTextChangedListener
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.ActivitySignUpBinding
import com.example.cpr2u_android.presentation.MainActivity
import com.example.cpr2u_android.presentation.base.BaseActivity
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.util.regex.Pattern

class SignUpActivity : BaseActivity<ActivitySignUpBinding>(R.layout.activity_sign_up) {
    private val authViewModel: AuthViewModel by viewModel()
    private var phoneNumber: String = ""
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        phoneNumber = intent.getStringExtra("phoneNumber").toString()
        initTextChangeEvent()
//        observeIsValidNickname()
        initConfirmClickListener()
    }

    private fun initConfirmClickListener() {
        binding.tvConfirm.setOnClickListener {
            if (binding.isError == false) {
                authViewModel.getNickname(binding.etNickname.text.toString())
                authViewModel.isValidNickname.observe(this) {
                    if (it) {
                        authViewModel.postSignUp(
                            nickname = binding.etNickname.text.toString(),
                            phoneNumber = phoneNumber,
                        )
                        authViewModel.isSuccess.observe(this) {
                            if (it) {
                                Timber.d("회원가입 성공")
                                navigateToNext()
                            } else {
                                Timber.d("회원가입 실패")
                            }
                        }
                    } else {
                        Timber.d("is valid -> false")
                        Toast.makeText(
                            this,
                            "중복된 닉네임입니다. 다른 닉네임을 입력해주세요.",
                            Toast.LENGTH_SHORT,
                        ).show()
                    }
                }
            } else if (binding.etNickname.text.isEmpty()) {
                binding.isError = true
                binding.tvErrorMessage.text = getString(R.string.signup_set_nickname)
            }
        }
    }

    private fun navigateToNext() {
        startActivity(Intent(this@SignUpActivity, MainActivity::class.java))
        finish()
    }

    private fun observeIsValidNickname() {
        authViewModel.isValidNickname.observe(this) {
            Timber.d("isValideNickname -> $it")
//            isValidNickname = it
        }
    }

    private fun initTextChangeEvent() {
        val ps =
            Pattern.compile("^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\u318D\\u119E\\u11A2\\u2022\\u2025a\\u00B7\\uFE55]+$")

        with(binding) {
            etNickname.addTextChangedListener {
                if (it != null) {
                    if (it.isNotEmpty()) {
                        isError = false
                        if (!ps.matcher(it).matches()) {
                            isError = true
                            tvErrorMessage.text = getString(R.string.signup_no_special_characters)
                        } else if (etNickname.text.length > 10) {
                            etNickname.setText(it.toString().subSequence(0, 10))
                            etNickname.setSelection(10)
                        }
                    } else {
                        isError = true
                        tvErrorMessage.text = getString(R.string.signup_set_nickname)
                    }
                }
            }
        }
    }
}
