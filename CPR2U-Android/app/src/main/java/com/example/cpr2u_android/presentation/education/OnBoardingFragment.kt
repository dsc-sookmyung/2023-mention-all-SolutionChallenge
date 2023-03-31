package com.example.cpr2u_android.presentation.education

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import com.example.cpr2u_android.databinding.FragmentOnBoardingBinding

// TODO: Rename parameter arguments, choose names that match
// the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
private const val ARG_PARAM1 = "param1"
private const val ARG_PARAM2 = "param2"

/**
 * A simple [Fragment] subclass.
 * Use the [OnBoardingFragment.newInstance] factory method to
 * create an instance of this fragment.
 */
class OnBoardingFragment : Fragment() {
    private lateinit var title: String
    private lateinit var description: String
    private var imageResource = 0
    private lateinit var tvTitle: TextView
    private lateinit var tvDescription: TextView
    private lateinit var image: ImageView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (arguments != null) {
            title =
                requireArguments().getString(ARG_PARAM1)!!
            description =
                requireArguments().getString(ARG_PARAM2)!!
            imageResource =
                requireArguments().getInt(ARG_PARAM3)
        }
    }

    private var _binding: FragmentOnBoardingBinding? = null

    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        // Inflate the layout for this fragment
        _binding = FragmentOnBoardingBinding.inflate(inflater, container, false)
        val view = binding.root
        tvTitle = binding.tvOnboardingTitle
        tvDescription = binding.tvOnboardingSubtitle
        image = binding.ivOnboarding
        tvTitle.text = title
        tvDescription.text = description
        image.setImageResource(imageResource)
        return view
    }

    companion object {
        private const val ARG_PARAM1 = "param1"
        private const val ARG_PARAM2 = "param2"
        private const val ARG_PARAM3 = "param3"
        fun newInstance(
            title: String,
            description: String,
            imageResource: Int,
        ): OnBoardingFragment {
            val fragment =
                OnBoardingFragment()
            val args = Bundle()
            args.putString(
                ARG_PARAM1,
                title,
            )
            args.putString(
                ARG_PARAM2,
                description,
            )
            args.putInt(
                ARG_PARAM3,
                imageResource,
            )
            fragment.arguments = args
            return fragment
        }
    }
}
