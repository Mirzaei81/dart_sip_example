package com.linotik.app;


import static android.database.sqlite.SQLiteDatabase.OPEN_READWRITE;

import android.Manifest;
import android.app.NotificationManager;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.sqlite.SQLiteDatabase;
import android.telephony.TelephonyManager;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

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
    private Context context;
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
                                this.requestPermissions(new String[]{Manifest.permission.READ_PHONE_STATE,Manifest.permission.READ_SMS,Manifest.permission.READ_PHONE_NUMBERS,android.Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.MANAGE_EXTERNAL_STORAGE,Manifest.permission.ACCESS_NOTIFICATION_POLICY,Manifest.permission.READ_CONTACTS},
                                        PERMISSION_CODE);
                                String dbPath = call.argument("db");
                                SQLiteDatabase db = SQLiteDatabase.openDatabase(dbPath,null,OPEN_READWRITE);
                                if(context!=null){
                                    TelephonyManager tMgr = (TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE);
                                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_NUMBERS) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                                        // TODO: Consider calling
                                        //    ActivityCompat#requestPermissions
                                        // here to request the missing permissions, and then overriding
                                        //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                        //                                          int[] grantResults)
                                        // to handle the case where the user grants the permission. See the documentation
                                        // for ActivityCompat#requestPermissions for more details.
                                        return;
                                    }
                                    String mPhoneNumber = tMgr.getLine1Number();
                                    ContentValues cv = new ContentValues();
                                    cv.put("username",mPhoneNumber);
                                    cv.put("password","");
                                    cv.put("uri","");
                                    System.out.println("Got new Phone number: "+mPhoneNumber);
                                    db.insert("accounts",null,cv);
                                }
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
                            }
                            else {
                                result.success(true);
                            }
                        }
                );
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        context = binding.getActivity().getApplicationContext();
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