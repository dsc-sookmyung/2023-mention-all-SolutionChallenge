package com.example.cpr2u_android.presentation.auth

import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import com.example.cpr2u_android.R
import com.example.cpr2u_android.databinding.FragmentSignUpAddressBinding
import com.example.cpr2u_android.presentation.MainActivity
import com.example.cpr2u_android.presentation.base.BaseFragment
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber

class SignUpAddressFragment :
    BaseFragment<FragmentSignUpAddressBinding>(R.layout.fragment_sign_up_address) {
    private val authViewModel: AuthViewModel by sharedViewModel()
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        var checked_sido_Position = 0
        var checked_gugun_position = 0
        var isSelected = false
        var addressId = 0

        val array = arrayOf<String>(
            "서울특별시", "부산광역시", "대구광역시", "인천광역시", "광주광역시", "대전광역시", "울산광역시", "세종특별자치시",
            "경기도", "강원도", "충청북도", "충청남도", "전라북도", "전라남도", "경상북도", "경상남도", "제주특별자치도",
        )

        val gugun_array: List<Array<String>> = listOf(
            arrayOf<String>(
                "종로구", "중구", "용산구", "성동구", "광진구", "동대문구", "중랑구", "성북구", "강북구", "도봉구", "노원구", "은평구", "서대문구", "마포구",
                "양천구", "강서구", "구로구", "금천구", "영등포구", "동작구", "관악구", "서초구", "강남구", "송파구", "강동구",
            ),
            arrayOf("중구", "서구", "동구", "영도구", "부산진구", "동래구", "남구", "북구", "해운대구", "사하구", "금정구", "강서구", "연제구", "수영구", "사상구", "기장군"),
            arrayOf("중구", "동구", "서구", "남구", "북구", "수성구", "달서구", "달성군"),
            arrayOf("중구", "동구", "남구", "연수구", "남동구", "부평구", "계양구", "서구", "강화군", "옹진군"),
            arrayOf("동구", "서구", "남구", "북구", "광산구"),
            arrayOf("동구", "중구", "서구", "유성구", "대덕구"),
            arrayOf("중구", "남구", "동구", "북구", "울주군"),
            arrayOf("세종특별자치시"),
            arrayOf(
                "수원시 장안구", "수원시 권선구", "수원시 팔달구", "수원시 영통구", "성남시 수정구", "성남시 중원구", "성남시 분당구", "의정부시", "안양시 만안구", "안양시 동안구",
                "부천시", "광명시", "평택시", "동두천시", "안산시 상록구", "안산시 단원구", "고양시 덕양구", "고양시 일산동구", "고양시 일산서구", "과천시", "구리시", "남양주시", "오산시",
                "시흥시", "군포시", "의왕시", "하남시", "용인시 처인구", "용인시 기흥구", "용인시 수지구", "파주시", "이천시", "안성시", "김포시", "화성시", "광주시", "양주시", "포천시", "여주시", "연천군", "가평군", "양평군",
            ),
            arrayOf("춘천시", "원주시", "강릉시", "동해시", "태백시", "속초시", "삼척시", "홍천군", "횡성군", "영월군", "평창군", "정선군", "철원군", "화천군", "양구군", "인제군", "고성군", "양양군"),
            arrayOf("청주시 상당구", "청주시 서원구", "청주시 흥덕구", "청주시 청원구", "충주시", "제천시", "보은군", "옥천군", "영동군", "증평군", "진천군", "괴산군", "음성군", "단양군"),
            arrayOf("천안시 동남구", "천안시 서북구", "공주시", "보령시", "아산시", "서산시", "논산시", "계룡시", "당진시", "금산군", "부여군", "서천군", "청양군", "홍성군", "예산군", "태안군"),
            arrayOf("전주시 완산구", "전주시 덕진구", "군산시", "익산시", "정읍시", "남원시", "김제시", "완주군", "진안군", "무주군", "장수군", "임실군", "순창군", "고창군", "부안군"),
            arrayOf("목포시", "여수시", "순천시", "나주시", "광양시", "담양군", "곡성군", "구례군", "고흥군", "보성군", "화순군", "장흥군", "강진군", "해남군", "영암군", "무안군", "함평군", "영광군", "장성군", "완도군", "진도군", "신안군"),
            arrayOf("포항시 남구", "포항시 북구", "경주시", "김천시", "안동시", "구미시", "영주시", "영천시", "상주시", "문경시", "경산시", "군위군", "의성군", "청송군", "영양군", "영덕군", "청도군", "고령군", "성주군", "칠곡군", "예천군", "봉화군", "울진군", "울릉군"),
            arrayOf("창원시 의창구", "창원시 성산구", "창원시 마산합포구", "창원시 마산회원구", "창원시 진해구", "진주시", "통영시", "사천시", "김해시", "밀양시", "거제시", "양산시", "의령군", "함안군", "창녕군", "고성군", "남해군", "하동군", "산청군", "함양군", "거창군", "합천군"),
            arrayOf("서귀포시", "제주시")
        )
        val arr_size = arrayOf(1, 26, 42, 50, 60, 65, 70, 75, 76, 118, 136, 150, 166, 181, 203, 227, 249)
        binding.tvSido.setOnClickListener {
            AlertDialog.Builder(requireContext())
                .setTitle("radio")
                .setSingleChoiceItems(
                    array,
                    checked_sido_Position,
                ) { _, which ->
                    Timber.tag("MyTag").d("which : %s", which)
                    checked_sido_Position = which
                }
                .setPositiveButton(
                    "ok",
                    object : DialogInterface.OnClickListener {
                        override fun onClick(dialog: DialogInterface?, which: Int) {
                            Timber.tag("MyTag").d("checkedItemPosition : %s", checked_sido_Position)
                            binding.tvSido.text = array[checked_sido_Position]
                            checked_gugun_position = 0
                            binding.tvGugun.text = ""
                            isSelected = false
                        }
                    },
                )
                .show()
        }

        binding.tvGugun.setOnClickListener {
            AlertDialog.Builder(requireContext())
                .setTitle("radio")
                .setSingleChoiceItems(
                    gugun_array[checked_sido_Position],
                    checked_gugun_position,
                ) { _, which ->
                    Timber.tag("MyTag").d("which : %s", which)
                    checked_gugun_position = which
                }
                .setPositiveButton(
                    "ok",
                    object : DialogInterface.OnClickListener {
                        override fun onClick(dialog: DialogInterface?, which: Int) {
                            Timber.tag("MyTag").d("checkedItemPosition : %s", checked_gugun_position)
                            binding.tvGugun.text = gugun_array[checked_sido_Position][checked_gugun_position]
                            isSelected = true
                            addressId = arr_size[checked_sido_Position] + checked_gugun_position
                            Timber.d("#addressID = $addressId")
                        }
                    },
                )
                .show()
        }

        binding.tvConfirm.setOnClickListener {
            if (isSelected) {
                Timber.d("addressId -> $addressId")
                authViewModel.postSignUp(addressId)
                authViewModel.isSuccess.observe(viewLifecycleOwner) {
                    if (it) {
                        startActivity(Intent(requireContext(), MainActivity::class.java))
                        activity?.finish()
                    }
                }
            }
        }
    }
}
