package com.example.cpr2u_android.presentation.auth

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.View.OnFocusChangeListener
import android.widget.EditText
import android.widget.Toast
import androidx.core.widget.addTextChangedListener
import androidx.navigation.fragment.findNavController
import com.example.cpr2u_android.R
import com.example.cpr2u_android.data.model.request.auth.RequestLogin
import com.example.cpr2u_android.data.sharedpref.CPR2USharedPreference
import com.example.cpr2u_android.databinding.FragmentLoginPhoneNumberCheckBinding
import com.example.cpr2u_android.presentation.MainActivity
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber

class LoginPhoneNumberCheckFragment :
    BaseFragment<FragmentLoginPhoneNumberCheckBinding>(R.layout.fragment_login_phone_number_check) {
    private val signInViewModel: AuthViewModel by sharedViewModel()
    private lateinit var smsCode: List<EditText>
    var smsCodeStr: String = ""
    var phoneNumber: String = ""

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        smsCode =
            listOf(binding.tvSmsCode1, binding.tvSmsCode2, binding.tvSmsCode3, binding.tvSmsCode4)

        initPhoneNumber()
        initClickEvent()
        initSmsCodeEvent()
    }

    private fun initPhoneNumber() {
        phoneNumber = arguments?.getString("phoneNumber").toString()
        binding.phoneNumber = phoneNumber
    }

    private fun initClickEvent() {
        binding.tvConfirm.setOnClickListener {
            smsCode.forEach {
                smsCodeStr += it.text.toString()
            }

            if (smsCodeStr.length < 4) {
                Toast.makeText(requireContext(), "코드를 모두 입력해주세요", Toast.LENGTH_SHORT).show()
            } else {
                Timber.d("smscode -> $smsCodeStr")
                Timber.d("view model code -> ${signInViewModel.validationCode.value}")
                if (smsCodeStr == signInViewModel.validationCode.value) {
                    signInViewModel.postLogin(
                        RequestLogin(
                            deviceToken = CPR2USharedPreference.getDeviceToken(),
                            phoneNumber = phoneNumber,
//                            CPR2USharedPreference.getDeviceToken(),
//                            smsCodeStr,
                        ),
                    )
                    signInViewModel.isUser.observe(viewLifecycleOwner) {
                        navigateToNext(it)
                    }
                } else {
                    Timber.d("코드 다름")
                }
            }
        }
    }

    private fun navigateToNext(it: Boolean) {
        if (it) {
            val intent =
                Intent(requireContext(), MainActivity::class.java)
            startActivity(intent)
            requireActivity().finishAffinity()
        } else {
            signInViewModel.setPhoneNumber(phoneNumber)
            findNavController().navigate(
                R.id.action_loginPhoneNumberCheckFragment_to_signUpNickNameFragment,
            )
        }
    }

    private fun initSmsCodeEvent() {
        for (i in 0..3) {
            smsCode[i].addTextChangedListener {
                if (i in 0..2) {
                    if (smsCode[i].length() > 0) {
                        smsCode[i + 1].requestFocus()
                    }
                }
            }
            smsCode[i].onFocusChangeListener = OnFocusChangeListener { view, hasFocus ->
                if (hasFocus) {
                    smsCode[i].text.clear()
                    smsCodeStr = ""
                }
            }
        }
    }
}
