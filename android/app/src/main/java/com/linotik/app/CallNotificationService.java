package com.linotik.app;
import java.time.Instant;
import static android.database.sqlite.SQLiteDatabase.OPEN_READONLY;
import static android.database.sqlite.SQLiteDatabase.OPEN_READWRITE;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import androidx.core.app.Person;
import androidx.core.app.RemoteInput;
import androidx.core.app.ServiceCompat;
import androidx.core.graphics.drawable.IconCompat;
import androidx.preference.Preference;
import androidx.preference.PreferenceManager;

import android.graphics.drawable.Icon;
import android.icu.text.SimpleDateFormat;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.text.format.DateFormat;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.jvtd.flutter_pjsip.PjSipManager;
import com.jvtd.flutter_pjsip.entity.MyBuddy;
import com.jvtd.flutter_pjsip.entity.MyCall;
import com.jvtd.flutter_pjsip.interfaces.MyAppObserver;

import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class CallNotificationService extends FirebaseMessagingService {
    private static final String TAG = "CallNotificationService";
    private static final String CALL_CHANNEL_ID = "Calls";
    private static final String MSG_CHANNEL_ID = "Messages";
    private static final String CALL_CHANNEL_NAME = "Call Notifications";
    private static final String MSG_CHANNEL_NAME = "Message Notifications";
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";
    private static final String TABLE_NAME = "person";
    private static final String COLUMN_PHONE_NUMBER = "phone_number";
    private static final String COLUMN_NAME = "name";
    private PjSipManager instance;

    private static final String KEY_TEXT_REPLY = "message";
    private  String host;

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READWRITE);
        Cursor cursor = db.query("accounts", null,null,null,null,null,null);
        String auth_user ;
        String password ;
        String uri ;
        if(cursor.moveToFirst()) {
            auth_user = cursor.getString(cursor.getColumnIndexOrThrow("username"));
            password = cursor.getString(cursor.getColumnIndexOrThrow("password"));
            uri = cursor.getString(cursor.getColumnIndexOrThrow("uri"));
        }else{
            auth_user  ="601";
            password = "6016o1";
            uri = "192.168.10.110";
        }

        try {
            instance = PjSipManager.getInstance();
            instance.deinit();
            MyAppObserver tmpObserver = new MyAppObserver() {
                @Override
                public void notifyRegState(long code, String reason, long expiration) {
                    Log.e(TAG,reason+code);
                }

                @Override
                public void notifyIncomingCall(MyCall call) {

                }

                @Override
                public void notifyCallState(MyCall call) {

                }

                @Override
                public void notifyCallMediaState(MyCall call) {

                }

                @Override
                public void notifyBuddyState(MyBuddy buddy) {

                }

                @Override
                public void notifyChangeNetwork() {

                }
            };
            instance.init(PjSipManager.observer==null?tmpObserver:PjSipManager.observer);
            instance.login(auth_user,password,uri,"5060");
            Log.d(TAG,"login successfully " + PjSipManager.mEndPoint.libGetState());
            cursor.close();
        } catch (Exception e) {
            Log.e(TAG,e.toString());
        }
        if (!remoteMessage.getData().isEmpty()) {
            handleCallNotification(remoteMessage.getData(),db);
            Log.d(TAG, "Message data payload: " + remoteMessage.getData());
        }
        super.onMessageReceived(remoteMessage);
    }

    private void handleCallNotification(Map<String, String> data,SQLiteDatabase db) {
        String contactNumber = Objects.requireNonNull(data.get("number")).trim();
        String handlerType = Objects.requireNonNull(data.get("type")).trim();
        String contactName = "";
        String imgPath = "";
        long personId =0;
        try{
            Cursor cursor = db.query(TABLE_NAME, new String[]{"id",COLUMN_NAME},COLUMN_PHONE_NUMBER+ " = ?",new String[]{contactNumber},null,null,null);
            if (cursor.moveToFirst()) {
                int nameColumnIndex = cursor.getColumnIndexOrThrow(COLUMN_NAME);
                contactName = cursor.getString(nameColumnIndex);
                int idColumnIndex = cursor.getColumnIndexOrThrow("id");
                personId = cursor.getLong(idColumnIndex);
                try {
                    imgPath = cursor.getString(cursor.getColumnIndexOrThrow("img_path"));
                } catch (IllegalArgumentException e) {
                    Log.e(TAG,"Image not found");
                }
                cursor.close();
            }else{
                ContentValues cv= new ContentValues();
                cv.put("name",contactNumber);
                cv.put("img_path",imgPath);
                cv.put("date",Instant.now().toEpochMilli());
                cv.put("phone_number",contactNumber);

                personId = db.insert(TABLE_NAME,null,cv);
                contactName= contactNumber;
            }

        } catch (Exception e){
            Log.d(TAG, "Failed to open or create database"+e.toString());
        }

        if (contactName.isEmpty()) {
            Log.e(TAG, "Missing callerName or callerNumber in FCM data");
        }
        createNotificationChannel();
        if(Objects.equals(handlerType, "Newchannel")){
            sendCallNotification(contactName, contactNumber,personId,imgPath,db);
        }else{
            try {
                sendMessageNotification(contactName,contactNumber, URLDecoder.decode(data.get("content"), StandardCharsets.UTF_8.toString()), db);
            } catch (UnsupportedEncodingException ignored) {
            }
        }
        db.close();
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


    private void sendMessageNotification(String callerName,String callerNumber,String content,SQLiteDatabase db){
        Cursor c = db.query("person",new String[]{"id"},"phone_number = ?",new String[]{callerName},null,null,null);
        long date = Instant.now().toEpochMilli();

        int personId = 1;
        try{
            if(c.moveToFirst()){
                c.getInt(c.getColumnIndexOrThrow("id"));
            }
        }catch (Exception e ){
        }
        ContentValues notifValue = new ContentValues();
        notifValue.put("content",content);
        notifValue.put("dateSend",date);
        notifValue.put("isPinned",false);
        notifValue.put("read",false);
        notifValue.put("isMine",false);
        notifValue.put("peerId",personId);


        long id = db.insert("messages",null,notifValue);

        Uri ringtoneUri = RingtoneManager.getActualDefaultRingtoneUri(this,RingtoneManager.TYPE_NOTIFICATION);
        RingtoneManager.getRingtone(getApplicationContext(),ringtoneUri).play();

        Intent readIntent = new Intent(this, ReadMessageReceiver.class);
        readIntent.putExtra("id",(int)id);
        PendingIntent readPendingIntent = PendingIntent.getBroadcast(
                this, 0, readIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        // Create RemoteInput for inline reply
        RemoteInput remoteInput = new RemoteInput.Builder(KEY_TEXT_REPLY)
                .setLabel("Type your reply...")
                .build();

        // Intent and PendingIntent for "Reply" action
        Intent replyIntent = new Intent(this, ReplyMessageReceiver.class);
        replyIntent.putExtra("id",(int)id);
        replyIntent.putExtra("number",callerNumber);
        replyIntent.putExtra("person",personId);
        replyIntent.putExtra("host",host);
        PendingIntent replyPendingIntent = PendingIntent.getBroadcast(
                this, 1, replyIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE
        );

        // Build Reply action with RemoteInput
        NotificationCompat.Action replyAction = new NotificationCompat.Action.Builder(
                android.R.drawable.ic_menu_send, "Reply", replyPendingIntent)
                .addRemoteInput(remoteInput)
                .build();

        // Build Read action
        NotificationCompat.Action readAction = new NotificationCompat.Action.Builder(
                android.R.drawable.ic_menu_view, "Read", readPendingIntent)
                .build();


        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, MSG_CHANNEL_ID)
                .setContentTitle(callerName)
                .setContentText(content)
                .setAutoCancel(true)
                .addAction(replyAction)
                .addAction(readAction)
                .setLights(0xff73FE99, 1000, 1000)
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
    private void sendCallNotification(String callerName, String callerNumber,long personId,String imgPath,SQLiteDatabase db) {
        Uri ringtoneUri = RingtoneManager.getActualDefaultRingtoneUri(getApplicationContext(),RingtoneManager.TYPE_RINGTONE);
        RingtoneManager.getRingtone(this,ringtoneUri).play();
        Vibrator vibrator = (Vibrator)this.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        long[] pattern = {0, 500, 1000};
        VibrationEffect vibrationEffect = VibrationEffect.createWaveform(pattern,1);
//        vibrator.vibrate(vibrationEffect); TODO

        Person.Builder callePerson = new Person.Builder()
                .setName(callerName.isEmpty()?"test":callerName)
                .setImportant(true);
        if(!imgPath.isEmpty()) {
            callePerson.setIcon(IconCompat.createWithContentUri(imgPath));
        }
        instance.deinit();
        SharedPreferences preferences =PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("caller_name",callerName);
        editor.putString("caller_number",callerNumber);
        editor.putString("caller_img_path",imgPath);
        editor.commit();

        Intent endCallIntent =  new Intent(this, CallActionReceiver.class);
        endCallIntent.setAction("ACTION_DECLINE");
        endCallIntent.putExtra("id",personId);
        PendingIntent endCallPendingIntent = PendingIntent.getBroadcast(this, 0, endCallIntent, PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
        Intent answerCallIntent =FlutterActivity.withNewEngine()
                .initialRoute(String.format("/outgoing?%s",callerNumber))
                .build(this);
        answerCallIntent.putExtra("number",callerNumber);
        PendingIntent answerCallPendingIntent = PendingIntent.getActivity(this, 1, answerCallIntent, PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);

        Intent incomingCall  = FlutterActivity.withNewEngine()
                .initialRoute("/incoming")
                .build(this);

        PendingIntent incomingPendingIntent = PendingIntent.getActivity(this,2,incomingCall,PendingIntent.FLAG_IMMUTABLE);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CALL_CHANNEL_ID)
                .setFullScreenIntent( // Make it a full-screen intent (requires the USE_FULL_SCREEN_INTENT permission)
                        incomingPendingIntent,
                        true
                )
                .setAutoCancel(true) // Don't automatically dismiss on tap
                .setOngoing(true) // Make it an ongoing notification
                .setContentTitle("Incoming Call")
                .setContentText(callerName)
                .addPerson(callePerson.build())
                .setOngoing(true)
                .setStyle(
                        NotificationCompat.CallStyle.forIncomingCall(callePerson.build(), endCallPendingIntent, answerCallPendingIntent))
                .setLights(0xff73FE99, 1000, 1000)
                .setSmallIcon(R.drawable.notification_logo)
                .setPriority(NotificationManager.IMPORTANCE_HIGH)
                .setSound(ringtoneUri)
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS|NotificationCompat.DEFAULT_SOUND|NotificationCompat.DEFAULT_VIBRATE);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(123,builder.build());
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Refreshed token: " + token);
        Context context = getApplicationContext();
        SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READWRITE);
        Cursor cursor = db.query("accounts", null,null,null,null,null,null);
        // Create a new thread to handle the network request asynchronously
        if (cursor.moveToFirst()) {
            String uri = cursor.getString(cursor.getColumnIndexOrThrow("uri"));
            new Thread(() -> {
                try {
                    SharedPreferences perf= PreferenceManager.getDefaultSharedPreferences(context);
                    // Construct the URL
                    String urlString = "http://" + uri + "/linotik_cgi/TokenCGI?15000";
                    URL url = new URL(urlString);

                    // Open HttpURLConnection
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestMethod("POST");
                    connection.setDoOutput(true);

                    // Set headers
                    Map<String, String> headers = new HashMap<>();
                    headers.put("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8");
                    headers.put("Accept-Language", "en-US,en;q=0.9");
                    headers.put("Cache-Control", "max-age=0");
                    headers.put("Connection", "keep-alive");
                    headers.put("Content-Type", "application/x-www-form-urlencoded");
                    headers.put("Origin", "http://" + uri);
                    headers.put("Referer", "http://" + uri + "/linotik_cgi/TokenCGI?15000");
                    headers.put("Sec-GPC", "1");
                    headers.put("Upgrade-Insecure-Requests", "1");
                    headers.put("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36");
                    headers.put("Cookie", "language=en; loginname=admin; password=OV%5B2%5CFXo%5CI%5CmOFK4O%7CS%7BQVOzPlHj%5CoHlPIPoPFe%7BQVm%3F; OsVer=51.18.0.50; Series=; Product=TG100; defaultpwd=; current=sms; Backto=; TabIndex=0; TabIndexwithback=0; curUrl=15000");

                    for (Map.Entry<String, String> entry : headers.entrySet()) {
                        connection.setRequestProperty(entry.getKey(), entry.getValue());
                    }

                    // Set request body
                    String data = "token=" + token;
                    OutputStream os = connection.getOutputStream();
                    os.write(data.getBytes());
                    os.flush();
                    os.close();

                    // Get response code
                    int statusCode = connection.getResponseCode();

                    if (statusCode != 200) {
                        Log.e(TAG, "send Token failed");
                        return;
                    }

                    // Save token in SharedPreferences
                    Log.w(TAG,token);

                    perf.edit().putString("token", token).apply();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }).start();
        }
    }
}