package com.ambulance.util;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * Sends OTP emails for the Forgot Password flow using Gmail SMTP.
 *
 * SETUP REQUIRED before this works:
 *   1. Download these two jars and put them in WebContent/WEB-INF/lib:
 *        - javax.mail-1.6.2.jar   https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.6.2/javax.mail-1.6.2.jar
 *        - javax.activation-1.2.0.jar  https://repo1.maven.org/maven2/com/sun/activation/javax.activation/1.2.0/javax.activation-1.2.0.jar
 *   2. Fill in GMAIL_ADDRESS and GMAIL_APP_PASSWORD below with a Gmail
 *      address and a 16-character App Password generated at
 *      https://myaccount.google.com/apppasswords (NOT your normal Gmail password).
 */
public class EmailService {

    // TODO: fill these in with your own Gmail address + App Password.
    private static final String GMAIL_ADDRESS = "YOUR_GMAIL_ADDRESS_HERE@gmail.com";
    private static final String GMAIL_APP_PASSWORD = "YOUR_16_CHAR_APP_PASSWORD_HERE";

    /**
     * Sends a one-time password to the given address. Returns true if the
     * message was handed off to Gmail successfully, false if sending failed
     * (e.g. bad credentials, no internet) - the caller should show an error
     * in that case rather than pretending the email went out.
     */
    public static boolean sendOtpEmail(String toAddress, String otp) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(GMAIL_ADDRESS, GMAIL_APP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(GMAIL_ADDRESS));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
            message.setSubject("Your Ambulance Management System password reset code");
            message.setText(
                "Your one-time password (OTP) to reset your account password is:\n\n" +
                "    " + otp + "\n\n" +
                "This code expires in 10 minutes. If you did not request this, you can ignore this email."
            );
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}
