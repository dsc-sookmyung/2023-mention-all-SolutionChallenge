package com.mentionall.cpr2u.util.twilio;

import org.springframework.stereotype.Component;

@Component
public class FakeTwilioUtil extends TwilioUtil {
    @Override
    public String makeCodeToVerify() {
        return "1111";
    }

    @Override
    public void sendSMS(String phoneNumber, String content) {
    }
}
