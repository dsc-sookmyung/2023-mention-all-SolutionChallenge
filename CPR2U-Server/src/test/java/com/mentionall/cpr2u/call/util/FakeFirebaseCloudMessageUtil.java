package com.mentionall.cpr2u.call.util;

import com.mentionall.cpr2u.util.fcm.FirebaseCloudMessageUtil;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

public class FakeFirebaseCloudMessageUtil extends FirebaseCloudMessageUtil {

    @Override
    public void sendFcmMessage(List<String> deviceTokenToSendList, String title, String body, Map<String, String> data) {
    }
}
