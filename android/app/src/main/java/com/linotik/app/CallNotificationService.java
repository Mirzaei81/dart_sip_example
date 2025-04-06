package com.linotik.app;
import static android.database.sqlite.SQLiteDatabase.OPEN_READONLY;

import androidx.core.app.NotificationCompat;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import androidx.core.app.RemoteInput;
import androidx.core.graphics.drawable.IconCompat;

import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.text.format.DateFormat;
import android.util.Log;
import androidx.core.app.Person;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import java.util.Date;
import java.util.Map;
import java.util.Objects;


public class CallNotificationService extends FirebaseMessagingService {

    private static final String TAG = "CallNotificationService";
    private static final String CALL_CHANNEL_ID = "Calls";
    private static final String MSG_CHANNEL_ID = "Messages";
    private static final String CALL_CHANNEL_NAME = "Call Notifications";
    private static final String MSG_CHANNEL_NAME = "Message Notifications";
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";
    private static final String TABLE_NAME = "contacts";
    private static final String COLUMN_PHONE_NUMBER = "phone_number";
    private static final String COLUMN_NAME = "name";

    private static final String KEY_TEXT_REPLY = "key_text_reply";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "From: " + remoteMessage.getFrom()+":"+ DateFormat.format("HH:mm:ss", new Date()).toString());
        if (!remoteMessage.getData().isEmpty()) {
            Log.d(TAG, "Message data payload: " + remoteMessage.getData());
            handleCallNotification(remoteMessage.getData());
        }

        if (remoteMessage.getNotification() != null) {
            Log.d(TAG, "Message Notification Body: " + remoteMessage.getNotification().getBody());
        }
        super.onMessageReceived(remoteMessage);
    }

    private void handleCallNotification(Map<String, String> data) {
        String contactNumber = data.get("number");
        String handlerType = data.get("type");
        String contactName = "";
        String imgPath = "";
        try{
            SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READONLY);
            Cursor cursor = db.query(TABLE_NAME, new String[]{COLUMN_NAME},COLUMN_PHONE_NUMBER+ " = ?",new String[]{contactNumber},null,null,null);
            if (cursor.moveToFirst()) {
                int nameColumnIndex = cursor.getColumnIndexOrThrow(COLUMN_NAME);
                contactName = cursor.getString(nameColumnIndex);
                imgPath = cursor.getString(cursor.getColumnIndexOrThrow("img_path"));
                cursor.close();
            }
            db.close();

        } catch (Exception e){
            Log.d(TAG, "Failed to open or create database"+e.toString());
        }

        if (contactName.isEmpty()) {
            Log.e(TAG, "Missing callerName or callerNumber in FCM data");
        }
        createNotificationChannel();
        if(Objects.equals(handlerType, "call")){
            sendCallNotification(contactName, contactNumber,imgPath);
        }else{
            sendMessageNotification(contactName,data.get("content"));
        }
    }

    private void createNotificationChannel() {
        NotificationChannel messageChannel = new NotificationChannel(
                MSG_CHANNEL_ID,
                MSG_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH // Important for call notifications
        );

        messageChannel.setDescription("Incoming call notifications");
        NotificationChannel callChannel = new NotificationChannel(
                CALL_CHANNEL_ID,
                CALL_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH // Important for call notifications
        );


        NotificationManager notificationManager = getSystemService(NotificationManager.class);
        if (notificationManager != null) {
            notificationManager.createNotificationChannel(messageChannel);
            notificationManager.createNotificationChannel(callChannel);
        }
    }


    private void sendMessageNotification(String callerName,String content){
        Intent endCallIntent =  new Intent(this, EndCall.class);
        endCallIntent.setAction("Mark as read");
        endCallIntent.putExtra("endCallId",0);
        PendingIntent endCallPendingIntent = PendingIntent.getBroadcast(this, 0, endCallIntent, PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
        Intent answerCallIntent =  new Intent(this, EndCall.class);
        endCallIntent.setAction("Reply");
        endCallIntent.putExtra("acceptCallId",0);
        PendingIntent startCallPendingIntent = PendingIntent.getBroadcast(this, 0, answerCallIntent, PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
        Log.d(TAG,"starting new Call intent");

        String replyLabel = getResources().getString(R.string.reply_label);
        RemoteInput remoteInput = new RemoteInput.Builder(KEY_TEXT_REPLY)
                .setLabel(replyLabel)
                .build();
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, MSG_CHANNEL_ID)
                .setContentTitle(callerName)
                .setContentText(content)
                .setAutoCancel(true)
                .setLights(0xff73FE99, 1000, 1000)
                .addAction(R.drawable.call_accept, "Mark as read", endCallPendingIntent)
                .addAction(R.drawable.call_reject, "Reply", startCallPendingIntent)
                .setSmallIcon(R.drawable.notification_logo)
                .setPriority(NotificationCompat.PRIORITY_HIGH) // High priority for call notifications
                .setCategory(NotificationCompat.CATEGORY_CALL) // Indicates it's a call notification
                .setFullScreenIntent(null, true) // Required for heads-up notifications
                .setDefaults(NotificationCompat.DEFAULT_VIBRATE | NotificationCompat.DEFAULT_SOUND | NotificationCompat.DEFAULT_LIGHTS)
                .setAutoCancel(true);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (notificationManager != null) {
            notificationManager.notify(1, builder.build()); // Unique notification ID
        }
    }
    private void sendCallNotification(String callerName, String callerNumber,String imgPath) {
        Person.Builder callePerson = new Person.Builder()
                .setName(callerName.isEmpty()?"test":callerName)
                .setImportant(true);
        if(!imgPath.isEmpty()) {
            callePerson.setIcon(IconCompat.createWithContentUri(imgPath));
        }

        Intent endCallIntent =  new Intent(this, EndCall.class);
        endCallIntent.setAction("Reject");
        endCallIntent.putExtra("endCallId",0);
        PendingIntent endCallPendingIntent = PendingIntent.getBroadcast(this, 0, endCallIntent, PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
        Intent answerCallIntent =  new Intent(this, EndCall.class);
        answerCallIntent.setAction("Accept");
        answerCallIntent.putExtra("acceptCallId",0);
        PendingIntent answerCallPendingIntent = PendingIntent.getBroadcast(this, 0, answerCallIntent, PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
        Log.d(TAG,"starting new Call intent");
        Uri ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CALL_CHANNEL_ID)
                .setFullScreenIntent(answerCallPendingIntent, true)
                .setContentTitle("Incoming Call")
                .setContentText(callerName)
                .addPerson(callePerson.build())
                .setStyle(
                        NotificationCompat.CallStyle.forIncomingCall(callePerson.build(), endCallPendingIntent, answerCallPendingIntent))
                .setLights(0xff73FE99, 1000, 1000)
                .setSmallIcon(R.drawable.notification_logo)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setSound(ringtoneUri)
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS|NotificationCompat.DEFAULT_SOUND|NotificationCompat.DEFAULT_VIBRATE);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (notificationManager != null) {
            notificationManager.notify(1, builder.build());
        }
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Refreshed token: " + token);
        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // FCM registration token to your app server.
        // sendRegistrationToServer(token);
    }
}