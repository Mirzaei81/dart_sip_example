package com.linotik.app;



import static android.database.sqlite.SQLiteDatabase.OPEN_READWRITE;
import static androidx.core.content.ContextCompat.startActivity;

import android.annotation.SuppressLint;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.util.Log;

import androidx.core.app.NotificationManagerCompat;


import com.jvtd.flutter_pjsip.PjSipManager;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;

public class CallActionReceiver extends BroadcastReceiver {
    private static String  TAG = "CallAction";
    @SuppressLint("SdCardPath")
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";
    private static final String TABLE_NAME = "accounts";
    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action != null) {
            switch (action) {
                case "ACTION_ANSWER":
                    Log.d(TAG,"Answering the call");
                    // Create an Intent to start your Activity
                    Intent activityIntent = new Intent(context,IncomingCallActivity.class);
                    // Create a PendingIntent
                    activityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    activityIntent.putExtras(Objects.requireNonNull(intent.getExtras()));

                    PendingIntent pendingIntent =
                            PendingIntent.getActivity(context, 0, activityIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                    try {
                        // Send the PendingIntent to start the Activity
                        context.startActivity(activityIntent,intent.getExtras());
//                        pendingIntent.send();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    break;
                case "ACTION_DECLINE":
                    SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READWRITE);
                    LocalDateTime now = LocalDateTime.now();
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
                    ContentValues cv = new ContentValues();

                    cv.put("personId", Objects.requireNonNull(intent.getExtras()).getLong("id",1));
                    cv.put("date",now.format(formatter));
                    cv.put("incoming",true);
                    cv.put("missed",true);
                    cv.put("record_path","");
                    db.insert("call_records",null,cv);

                    int notificationId = intent.getIntExtra("Notification_ID", 1);
                    NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
                    notificationManager.cancel(notificationId);
                    PjSipManager instence =  PjSipManager.getInstance();
                    try {
                        instence.libRegThread(Thread.currentThread().getName());
                        instence.hangup();
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                    Uri ringtoneUri = RingtoneManager.getActualDefaultRingtoneUri(context,RingtoneManager.TYPE_RINGTONE);
                    RingtoneManager.getRingtone(context,ringtoneUri).stop();
                    Vibrator vibrator = (Vibrator) context.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
                    vibrator.cancel();
                    break;
            }
            // Important: Cancel the notification after handling the action
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancel(123); // Use the same NOTIFICATION_ID
        }
    }
}
