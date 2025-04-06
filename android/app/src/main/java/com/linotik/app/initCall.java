package com.linotik.app;



import static androidx.core.content.ContextCompat.startActivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import io.flutter.embedding.android.FlutterActivity;



public class initCall extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
       startActivity(context,FlutterActivity.withNewEngine().initialRoute("/incoming").build(context),null);
    }
}
