package com.mentionall.cpr2u.util.fcm;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.*;
import com.mentionall.cpr2u.util.exception.CustomException;
import com.mentionall.cpr2u.util.exception.ResponseCode;
import com.mentionall.cpr2u.util.fcm.FcmDataType;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class FirebaseCloudMessageUtil {
    public static FirebaseApp firebaseApp;
    public static final String firebaseAppName = "CPR2U";

    @PostConstruct
    private void initialFirebaseApp() throws IOException {
        String firebaseConfigPath = "firebase/firebase_service_key.json";
        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(new ClassPathResource(firebaseConfigPath).getInputStream()))
                .build();

        firebaseApp = FirebaseApp.initializeApp(options, firebaseAppName);
    }

    public void sendFcmMessage(List<String> deviceTokenToSendList, String title, String body, Map<String, String> data) {

        if (deviceTokenToSendList.size() > 0) {
            MulticastMessage message = MulticastMessage.builder()
                    .addAllTokens(deviceTokenToSendList)
                    .setAndroidConfig(AndroidConfig.builder()
                            .putAllData(creatDataForAOS(title, body, data))
                            .build())
                    .setApnsConfig(ApnsConfig.builder()
                            .putAllCustomData(createDataForiOS(data))
                            .setAps(Aps.builder()
                                    .setContentAvailable(true)
                                    .setAlert(ApsAlert.builder()
                                            .setTitle(title)
                                            .setBody(body)
                                            .build())
                                    .build())
                            .build())
                    .build();

            try {
                FirebaseMessaging.getInstance(firebaseApp).sendMulticast(message);
            } catch (FirebaseMessagingException e) {
                throw new CustomException(ResponseCode.SERVER_ERROR_FAILED_TO_SEND_FCM);
            }
        }
    }

    @NotNull
    private static LinkedHashMap<String, String> creatDataForAOS(String title, String body, Map<String, String> data) {
        LinkedHashMap<String, String> dataForAOS = new LinkedHashMap<>() {{
            put(FcmDataType.TITLE.getType(), title);
            put(FcmDataType.BODY.getType(), body);
        }};
        dataForAOS.putAll(data);
        return dataForAOS;
    }

    @NotNull
    private static LinkedHashMap<String, Object> createDataForiOS(Map<String, String> data) {
        LinkedHashMap<String, Object> dataForiOS = new LinkedHashMap<>();
        dataForiOS.putAll(data);
        return dataForiOS;
    }

}