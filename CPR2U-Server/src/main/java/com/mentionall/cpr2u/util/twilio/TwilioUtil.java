package com.mentionall.cpr2u.util.twilio;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.rest.verify.v2.service.Verification;
import com.twilio.type.PhoneNumber;
import org.springframework.stereotype.Component;

@Component
public class TwilioUtil {
    //@Value("${security.twilio.account-sid}")
    private String twilioAccountSid;
    //@Value("${security.twilio.auth-token}")
    private String twilioAuthToken;

    //@Value("${security.twilio.service-sid}")
    private String twilioServiceSid;

    public String makeCodeToVerify(){
        return String.format("%04.0f", Math.random() * Math.pow(10, 4));
    }
    public void sendSMS(String phoneNumber, String content) {
        Twilio.init(twilioAccountSid, twilioAuthToken);

        Verification.creator(
                        twilioServiceSid,
                        phoneNumber,
                        "sms");

        Message.creator(new PhoneNumber(phoneNumber), new PhoneNumber(phoneNumber), content).create();
    }
}
