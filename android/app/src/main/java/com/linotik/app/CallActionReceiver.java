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

        int notificationId = intent.getIntExtra("Notification_ID", 123);
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        notificationManager.cancel(notificationId);
        notificationManager.cancel(123); // Use the same NOTIFICATION_ID
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
        // Important: Cancel the notification after handling the action
    }
}
