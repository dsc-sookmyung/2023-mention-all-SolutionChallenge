package com.example.cpr2u_android.util

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.cpr2u_android.R
import com.example.cpr2u_android.presentation.MainActivity
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import timber.log.Timber
import java.util.Date

class FirebaseService : FirebaseMessagingService() {
    var jsonType: String = ""
    private var bundle = Bundle()
    override fun onNewToken(token: String) {
        Log.d("MyFcmService", "New token :: $token")
        sendTokenToServer(token)
    }

    private fun sendTokenToServer(token: String) {
        // TODO :: TOKEN 값을 서버에 저장
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // TODO :: 전달받은 리모트 메시지를 처리

        val pm =
            getSystemService(POWER_SERVICE) as PowerManager

        @SuppressLint("InvalidWakeLockTag")
        val wakeLock =
            pm.newWakeLock(
                PowerManager.SCREEN_DIM_WAKE_LOCK
                    or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "TAG",
            )
        wakeLock.acquire(3000)
        wakeLock.release()

        Timber.tag("MyFcmService").d("Notification :: " + remoteMessage)
        Timber.tag("MyFcmService").d("Notification :: " + remoteMessage.data)

        // Check if message contains a data payload.
        if (remoteMessage.data.isNotEmpty()) {
            Timber.d("Title ${remoteMessage.data["title"]}")
            Timber.d("Body ${remoteMessage.data["body"]}")

            remoteMessage.data?.let {
                val intent = Intent(this, MainActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                val pendingIntent = PendingIntent.getActivity(
                    this,
                    0,
                    intent,
                    PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
                showNotification(
                    pendingIntent,
                    remoteMessage.data["title"]!!,
                    remoteMessage.data["body"]!!,
                )
            }
        }
    }

    private fun showNotification(pIntent: PendingIntent, title: String, body: String) {
        /*
        1. 알림(노티피케이션)을 누를 시 이동할 화면을 정하여 Intent 객체를 생성한다.
        2. 이 인텐트는 당장 실행되는 것이 아니라 지연되므로 PendingIntent를 생성하여 위 Intent를 담는다.
        3. NotificationCompat.Builder를 사용할 채널 id 값을 전달하여 생성한다.
        4. 우선순위와 아이콘, 제목, 내용, 그리고 PendingIntent를 전달한다.
        5. NotificationManager 객체를 얻고, Android 8.0 이상인 경우 채널을 생성하도록 하고 알림을 띄운다.

        데이터를 백그라운드, 포그라운드에서 모두 접근하여 활용하려면 서버측에서 전송 시 노티피케이션 부분을 제거하고 데이터만 포함하도록 해야한다.
         */
        val channelId = "CPR2U_channel"

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setFullScreenIntent(null, true)
            .setAutoCancel(true)
            .setContentIntent(pIntent)

        getSystemService(NotificationManager::class.java).run {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel =
                    NotificationChannel(channelId, "알림", NotificationManager.IMPORTANCE_HIGH)
                createNotificationChannel(channel)
            }

            notify(Date().time.toInt(), notificationBuilder.build())
        }
    }
}
