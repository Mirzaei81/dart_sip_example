package com.linotik.app;

import static android.database.sqlite.SQLiteDatabase.OPEN_READWRITE;

import android.annotation.SuppressLint;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.os.Bundle;
import android.util.Log;

import androidx.core.app.RemoteInput;
import androidx.work.Data;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.WorkRequest;

public class ReplyMessageReceiver extends BroadcastReceiver{
    private final static String  TAG = "messageNotification";
    @SuppressLint("SdCardPath")
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";
    @Override
    public void onReceive(Context context,Intent intent) {
        Bundle b = intent.getExtras();
        try{
            SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READWRITE);
            ContentValues cv = new ContentValues();
            cv.put("read","1");
            db.update("messages",cv,"id = ?",new String[]{b != null ? b.getString("id") : "1"});
        } catch (SQLiteException e) {
            Log.e(TAG,"can't open db \n\n"+ e);
        }
        assert  b!=null;
        String msg = RemoteInput.getResultsFromIntent(intent).getString("message","");
        String number = b.getString("number","601");
        String  personId = b.getString("person","1");
        String  host = b.getString("host","192.168.10.110");
        Log.d(TAG,msg+number+personId+host);
        Data inputData = new Data.Builder()
                .putString("message",msg)
                .putString("number",number)
                .putString("host",host)
                .putString("personId",personId)
                .build();


        WorkRequest workRequest = new OneTimeWorkRequest.Builder(SendMessage.class)
                .setInputData(inputData)
                .build();
        WorkManager.getInstance(context).cancelAllWork();
        WorkManager.getInstance(context).enqueue(workRequest);

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(123); // Use the same NOTIFICATION_ID
    }
}
