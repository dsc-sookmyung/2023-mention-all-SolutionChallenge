package com.example.cpr2u_android.presentation.call

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.location.Address
import android.location.Geocoder
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.flowWithLifecycle
import androidx.lifecycle.lifecycleScope
import com.example.cpr2u_android.R
import com.example.cpr2u_android.data.model.response.call.ResponseCallList
import com.example.cpr2u_android.databinding.FragmentCallBinding
import com.example.cpr2u_android.domain.model.CallInfoBottomSheet
import com.example.cpr2u_android.util.UiState
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationListener
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.*
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.maps.android.SphericalUtil
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.androidx.viewmodel.ext.android.viewModel
import timber.log.Timber
import java.util.*
import kotlin.properties.Delegates


class CallFragment : Fragment(), OnMapReadyCallback, LocationListener, GoogleMap.OnMyLocationChangeListener {
    private val callViewModel: CallViewModel by viewModel()
    private lateinit var binding: FragmentCallBinding
    private val locationPermissionCode = 100
    lateinit var mapFragment: MapView

    private lateinit var mMap: GoogleMap
    private lateinit var mLocationManager: LocationManager
    private lateinit var mMarker: Marker
    private lateinit var progressBell: ProgressBar
    private lateinit var fadeIn: View
    private lateinit var fadeInAnim: Animation
    private lateinit var fadeInText: TextView
    private lateinit var bell: ImageView
    private var timerStarted = false
    private var timeLeftInMillis = 0L
    private lateinit var countDownTimer: CountDownTimer
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var latitude by Delegates.notNull<Double>()
    private var longitude by Delegates.notNull<Double>()
    private lateinit var address: Address
    private lateinit var fullAddress: String

    private var timerSec: Int = 0
    private var time: TimerTask? = null
    private var timerText: TextView? = null
    private val handler: Handler = Handler()
    private lateinit var updater: Runnable

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        binding = FragmentCallBinding.inflate(layoutInflater, container, false)
        val view: View = inflater.inflate(R.layout.fragment_call, container, false)

        MapsInitializer.initialize(requireContext(), MapsInitializer.Renderer.LATEST) {
            // println(it.name)
        }
        mapFragment = view.findViewById<MapView>(R.id.mapFragment)
        mapFragment.onCreate(savedInstanceState)
        mapFragment.getMapAsync(this)

        bell = view.findViewById<ImageView>(R.id.iv_bell)
        progressBell = view.findViewById<ProgressBar>(R.id.progress_bar_bell)
        progressBell.visibility = View.GONE

        fadeIn = view.findViewById<View>(R.id.fade_in)
        fadeInAnim = AnimationUtils.loadAnimation(context, R.anim.fade_in)
        fadeInText = view.findViewById<TextView>(R.id.tv_fade_in)
        fadeIn.visibility = View.INVISIBLE
        progressBell.visibility = View.INVISIBLE
        fadeInText.visibility = View.INVISIBLE

        initTimer()

        bell.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    fadeIn.startAnimation(fadeInAnim)
                    fadeIn.setBackgroundColor(Color.parseColor("#42FF2F2F"))
                    startTimer()
                    return@setOnTouchListener true
                }

                MotionEvent.ACTION_UP -> {
                    fadeIn.visibility = View.INVISIBLE
                    progressBell.visibility = View.INVISIBLE
                    fadeInText.visibility = View.INVISIBLE
                    fadeIn.clearAnimation()
                    resetTimer()
                }
            }
            true
        }
        return view
    }

    private fun initTimer() {
        Timber.d("#### init Timer")
        countDownTimer = object : CountDownTimer(4000, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                Timber.d("onTick 호출...")
                fadeIn.visibility = View.VISIBLE
                progressBell.visibility = View.VISIBLE
                fadeInText.visibility = View.VISIBLE
                timeLeftInMillis = millisUntilFinished
                val secondsLeft = timeLeftInMillis / 1000
                fadeInText.text = secondsLeft.toString()
            }

            override fun onFinish() {
                Timber.d("onFinish 호출")
                fadeIn.visibility = View.INVISIBLE
                progressBell.visibility = View.INVISIBLE
                fadeInText.visibility = View.INVISIBLE
                // TODO : 호출 서버통신
                callViewModel.postCall(latitude, longitude, fullAddress)
                callViewModel.callUIState.flowWithLifecycle(lifecycle).onEach {
                    when (it) {
                        is UiState.Success -> {
                            Timber.d("post call success")
                            val bundle =
                                Bundle().apply { putInt("callId", callViewModel._callId) }
                            Timber.d("####1 startAcitivy 합니다..")
                            startActivity(
                                Intent(
                                    requireContext(),
                                    CallingActivity::class.java,
                                ).putExtras(bundle),
                            )
                            timerStarted = false
                            callViewModel.setCallUiState()
                            resetTimer()
                            initTimer()
                            return@onEach
                        }
                        else -> {
                            Timber.d("로딩도 아니고.. 성공도 아니고.. ")
                        }
                    }
                }.launchIn(lifecycleScope)
            }
        }
    }

    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(requireContext())

        // Check for permission to access location
        if (ContextCompat.checkSelfPermission(
                requireContext(),
                Manifest.permission.ACCESS_FINE_LOCATION,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            // Get current location
            fusedLocationClient.lastLocation.addOnSuccessListener(
                requireActivity(),
                OnSuccessListener<Location> { location ->
                    // Got last known location. In some rare situations, this can be null.
                    if (location != null) {
                        // Get latitude and longitude from location
                        latitude = location.latitude
                        longitude = location.longitude
                        // Use the latitude and longitude as needed
                        Log.d("LOCATION : ", "Latitude: $latitude, Longitude: $longitude")

                        val markerOptions = MarkerOptions().apply {
                            position(LatLng(latitude, longitude))
                            title("Current Location")
                        }
                        // 내 위치 마커 찍기
                        mMap.isMyLocationEnabled = true
//                        mMap.addMarker(markerOptions)

                        // 카메라 이동 및 줌인
                        mMap.moveCamera(
                            CameraUpdateFactory.newLatLngZoom(
                                LatLng(
                                    latitude,
                                    longitude,
                                ),
                                15f,
                            ),
                        )

                        val geocoder = Geocoder(requireContext(), Locale.getDefault())
                        val addresses: List<Address>? = geocoder.getFromLocation(
                            latitude,
                            longitude,
                            1,
                        )

                        if (addresses != null) {
                            if (addresses.isNotEmpty()) {
                                address = addresses[0]
                                fullAddress = address.getAddressLine(0) // full address name
                                Timber.d("ADDRESS : $address")
                                Timber.d("FULL ADDRESS : $fullAddress")
                                val tvLocation = view?.findViewById<TextView>(R.id.tv_location)
                                tvLocation?.text = fullAddress.substring(5, fullAddress.length)
                            }
                        }
                    }
                },
            ).addOnFailureListener(
                requireActivity(),
                OnFailureListener { e ->
                    // Handle failure
                },
            )
        } else {
            // Request permission to access location
            ActivityCompat.requestPermissions(
                requireActivity(),
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                LOCATION_PERMISSION_REQUEST_CODE,
            )
        }

        callViewModel.getCallList()
        lateinit var callList: ResponseCallList
        callViewModel.callListInfo.observe(viewLifecycleOwner) {
            callList = it
            val listNum = it.data.callList.size
            for (i in 0 until listNum) {
                val nLatitude = it.data.callList[i].latitude
                val nLongitude = it.data.callList[i].longitude
                val nMarkerOptions = MarkerOptions().apply {
                    position(LatLng(nLatitude, nLongitude))
                    title("${it.data.callList[i].cprCallId}")
                }
                mMap.addMarker(nMarkerOptions)
            }
        }

        // 마커를 클릭하면 BottomSheet를 띄움
        mMap.setOnMarkerClickListener { marker ->
            Timber.d("위치 -----> ${marker.position.latitude}")
            Timber.d("CALL ID -> ${marker.title}")
            if (marker.title != "Current Location") {
                val distance = SphericalUtil.computeDistanceBetween(
                    LatLng(latitude, longitude),
                    LatLng(marker.position.latitude, marker.position.longitude),
                )
                var distanceStr = ""
                distanceStr = if (distance < 1000) {
                    String.format("%.2f", distance) + "m"
                } else {
                    String.format("%.2f", distance / 1000) + "km"
                }
                val duration =
                    if (distance / 100 < 1) "1" else String.format("%.0f", distance / 100)
                val address = callList.data.callList.find {
                    it.cprCallId.toString() == marker.title
                }
                Timber.d("address -> $address")
                val productInfoFragment = CallInfoBottomSheetDialog(
                    CallInfoBottomSheet(
                        callId = marker.title!!.toInt(),
                        distance = distanceStr,
                        duration = duration,
                        fullAddress = address!!.fullAddress,
                    ),
                )
                productInfoFragment.show(requireFragmentManager(), "TAG")
            }
            true
        }
    }

    private fun startTimer() {
        countDownTimer.cancel()
        countDownTimer.start()
        timerStarted = true
    }

    private fun resetTimer() {
        timerSec = 0
        countDownTimer.cancel()
        timerStarted = false
        timeLeftInMillis = 0L
        fadeInText.text = "0"
    }

    override fun onStart() {
        super.onStart()
        mapFragment.onStart()
    }

    override fun onStop() {
        super.onStop()
        mapFragment.onStop()
        resetTimer()
    }

    override fun onResume() {
        super.onResume()
//        mapFragment.onResume()
        initTimer()
        countDownTimer.cancel()
        Timber.d("############resume")
    }

    override fun onDestroy() {
        super.onDestroy()
        mapFragment
    }

    override fun onLowMemory() {
        super.onLowMemory()
    }

    override fun onLocationChanged(location: Location) {
        location ?: return

        // Add a marker for the user's current location
        if (::mMarker.isInitialized) {
            mMarker.remove()
        }
        mMarker =
            mMap.addMarker(
                MarkerOptions().position(LatLng(location.latitude, location.longitude))
                    .title("Current Location"),
            )!!
        mMap.animateCamera(
            CameraUpdateFactory.newLatLngZoom(
                LatLng(
                    location.latitude,
                    location.longitude,
                ),
                15f,
            ),
        )
        // Stop updating the user's location to save battery
//        mLocationManager.removeUpdates(this)
    }

    companion object {
        /** Long Press 판단 기준 시간 */
        private const val LONG_PRESSED_TIME = 2L
        private const val LOCATION_PERMISSION_REQUEST_CODE = 100
    }

    override fun onMyLocationChange(location: Location) {
        val d1: Double = location.latitude
        val d2: Double = location.longitude
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(d1, d2), 15f))
    }
}