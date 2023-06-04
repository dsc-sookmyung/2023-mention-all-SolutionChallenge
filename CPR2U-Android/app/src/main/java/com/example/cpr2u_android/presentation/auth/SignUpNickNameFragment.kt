package com.example.cpr2u_android.presentation.auth

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.core.widget.addTextChangedListener
import androidx.navigation.fragment.findNavController
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentSignUpNickNameBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.util.regex.Pattern

class SignUpNickNameFragment :
    BaseFragment<FragmentSignUpNickNameBinding>(R.layout.fragment_sign_up_nick_name) {
    private val authViewModel: AuthViewModel by sharedViewModel()
    private var phoneNumber: String = ""

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initConfirmClickListener()
        initTextChangeEvent()
    }

    private fun initConfirmClickListener() {
        binding.tvConfirm.setOnClickListener {
            if (binding.isError == false) {
                authViewModel.getValidNickname(binding.etNickname.text.toString())
                authViewModel.isValidNickname.observe(requireActivity()) {
                    if (it) {
                        authViewModel.setNickname(binding.etNickname.text.toString())
                        navigateToNext()
                    } else {
                        Timber.d("is valid -> false")
                        Toast.makeText(
                            requireActivity(),
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
        findNavController().navigate(
            R.id.action_signUpNickNameFragment_to_signUpAddressFragment,
        )
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
