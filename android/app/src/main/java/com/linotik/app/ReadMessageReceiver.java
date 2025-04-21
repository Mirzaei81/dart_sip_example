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

public class ReadMessageReceiver  extends BroadcastReceiver {
    private static String  TAG = "messageNotification";
    @SuppressLint("SdCardPath")
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";
    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle b = intent.getExtras();
        try{
            SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READWRITE);
            ContentValues cv = new ContentValues();
            cv.put("read","1");
            db.update("messages",cv,"id = ?",new String[]{b != null ? b.getString("id") : "1"});
            db.close();
        } catch (SQLiteException e) {
            Log.e(TAG,"can't open db \n\n"+ e);
        }
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(123); // Use the same NOTIFICATION_ID
    }
}
