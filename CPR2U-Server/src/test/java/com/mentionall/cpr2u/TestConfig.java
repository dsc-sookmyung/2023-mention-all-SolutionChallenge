package com.mentionall.cpr2u;

import com.mentionall.cpr2u.call.util.FakeFirebaseCloudMessageUtil;
import com.mentionall.cpr2u.util.fcm.FirebaseCloudMessageUtil;
import com.mentionall.cpr2u.util.twilio.FakeTwilioUtil;
import com.mentionall.cpr2u.util.twilio.TwilioUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TestConfig {
    @Bean
    public FirebaseCloudMessageUtil firebaseCloudMessageUtil() {
        return new FakeFirebaseCloudMessageUtil();
    }

    @Bean
    public TwilioUtil twilioUtil(){
        return new FakeTwilioUtil();
    }
}
