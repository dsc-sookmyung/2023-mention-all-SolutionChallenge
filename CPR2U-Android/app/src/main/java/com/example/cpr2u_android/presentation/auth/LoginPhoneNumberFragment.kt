package com.example.cpr2u_android.presentation.auth

import android.os.Bundle
import android.view.View
import androidx.core.widget.addTextChangedListener
import androidx.navigation.fragment.findNavController
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentLoginPhoneNumberBinding
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import timber.log.Timber

class LoginPhoneNumberFragment :
    BaseFragment<FragmentLoginPhoneNumberBinding>(R.layout.fragment_login_phone_number) {
    private val signInViewModel: AuthViewModel by sharedViewModel()
    private var bundle = Bundle()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initClickEvent()
        observePhoneNumber()
    }

    private fun observePhoneNumber() {
        binding.etNumber.addTextChangedListener {
            binding.tvSend.isSelected = !it.isNullOrEmpty()
        }
    }

    private fun initClickEvent() {
        binding.tvSend.setOnClickListener {
            if (binding.tvSend.isSelected) {
                val phoneNumber = binding.etNumber.text.toString()
                Timber.d("### set phone number fragment -> ${phoneNumber}")
                signInViewModel.setPhoneNumber(phoneNumber)
                signInViewModel.postVerification(phoneNumber)
                signInViewModel.validationCode.observe(viewLifecycleOwner) {

                    Timber.d("signIn ViewModel V C -> ${signInViewModel.getValidationCode()}")
                    bundle = Bundle().apply {
                        putString("phoneNumber", binding.etNumber.text.toString())
                    }
                    findNavController().navigate(
                        R.id.action_loginPhoneNumberFragment_to_loginPhoneNumberCheckFragment,
                        bundle,
                    )
                }
            }
        }
    }
}
