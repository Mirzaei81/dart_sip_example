package com.linotik.app;

import static android.content.Context.MODE_PRIVATE;
import static android.database.sqlite.SQLiteDatabase.OPEN_READONLY;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import androidx.preference.PreferenceManager;

import com.jvtd.flutter_pjsip.PjSipManager;

public class EndCall extends BroadcastReceiver {

    @SuppressLint("SdCardPath")
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";
    private static final String TABLE_NAME = "accounts";
    @Override
    public void onReceive(Context context, Intent intent) {
        SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READONLY);
        Cursor cursor = db.query(TABLE_NAME, null,null,null,null,null,null);
        if(cursor.moveToFirst()){
            String auth_user =cursor.getString(cursor.getColumnIndexOrThrow("username"));
            String password = cursor.getString(cursor.getColumnIndexOrThrow("password"));
            String uri = cursor.getString(cursor.getColumnIndexOrThrow("uri"));
            PjSipManager instence =  PjSipManager.getInstance();
            instence.init(PjSipManager.observer);

            instence.login(auth_user,password,uri,"5060");
            instence.hangup();
        }
    }
}