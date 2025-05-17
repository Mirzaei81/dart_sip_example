package com.linotik.app;


import android.Manifest;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.jvtd.flutter_pjsip.utils.MethodResultWrapper;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements ActivityAware {
    private static final String CHANNEL = "com.linotik.app/main";

    private static final int PERMISSION_CODE = 1001; // Define a unique request code for permissions
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, rawresult) -> {
                            MethodResultWrapper result  = new MethodResultWrapper(rawresult);
                            if(call.method.equals("cancel")){
                                try {
                                    NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                                    notificationManager.cancel(123);
                                    result.success(true);
                                } catch (Exception e) {
                                    result.error("Failed",e.toString(),null);
                                }
                            } else if (call.method.equals("request_permissions")) {
                                this.requestPermissions(new String[]{Manifest.permission.READ_PHONE_STATE,android.Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.MANAGE_EXTERNAL_STORAGE,Manifest.permission.ACCESS_NOTIFICATION_POLICY,Manifest.permission.READ_CONTACTS},
                                        PERMISSION_CODE);
                                result.success(true);

                            } else if (call.method.equals("report_crash")){
                                try {
                                    Process process = Runtime.getRuntime().exec("logcat -d");
                                    BufferedReader bufferedReader = new BufferedReader(
                                            new InputStreamReader(process.getInputStream()));

                                    StringBuilder log=new StringBuilder();
                                    log.append("******APPLICATION LOG**************");
                                    String line = "";
                                    while ((line = bufferedReader.readLine()) != null) {
                                        log.append(line);
                                    }
                                    log.append("******APPLICATION LOG END***********");
                                    Intent intent = new Intent(Intent.ACTION_SEND);

                                    // Add email details using putExtra
                                    intent.putExtra(Intent.EXTRA_EMAIL, new String[]{"aam.mirzaei@gmail.com"});
                                    intent.putExtra(Intent.EXTRA_SUBJECT, "Phone call failure");
                                    intent.putExtra(Intent.EXTRA_TEXT, log.toString());
                                    intent.setType("message/rfc822");
                                    startActivity(Intent.createChooser(intent,"Choose email Client"));
                                    result.success(true);
                                }
                                catch (IOException e) {}
                            }else {
                                result.success(true);
                            }
                        }
                );
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(123);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}