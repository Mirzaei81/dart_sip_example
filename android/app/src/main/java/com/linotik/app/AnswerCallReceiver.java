package com.linotik.app;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.annotation.SuppressLint;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.os.Bundle;
import android.os.Vibrator;
import android.text.TextPaint;
import android.util.Log;
import android.view.MotionEvent;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.jvtd.flutter_pjsip.PjSipManager;

import io.flutter.embedding.android.FlutterActivity;

public class AnswerCallReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle b =intent.getExtras();

        System.out.println(String.format("starting activity from %s",AnswerCallReceiver.class.getName()));
        assert b != null;

        // handling notif cancelation
        NotificationManager notificationManager = (NotificationManager)  context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(123);
        Vibrator vibrator = (Vibrator) context.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        vibrator.cancel();
        // handling notif cancelation

        String callerNumber =  b.getString("callerNumber");
        System.out.println(String.format("calling %s and starting activity from %s",callerNumber,AnswerCallReceiver.class.getName()));
        Intent answerCallIntent =FlutterActivity.withNewEngine()
                .initialRoute(String.format("/outgoing?%s",callerNumber))
                .build(context);
        answerCallIntent.putExtra("number",callerNumber);
        context.startActivity(answerCallIntent);

    }
}
