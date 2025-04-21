package com.linotik.app;

import static android.database.sqlite.SQLiteDatabase.OPEN_READWRITE;

import android.annotation.SuppressLint;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.icu.text.SimpleDateFormat;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.work.CoroutineWorker;
import androidx.work.Data;
import androidx.work.WorkerParameters;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.Socket;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.Callable;

import kotlin.coroutines.Continuation;

public class SendMessage extends CoroutineWorker {
    private  final String Tag = "sendMessage";
    @SuppressLint("SdCardPath")
    private static final String DATABASE_NAME = "/data/user/0/com.linotik.app/databases/linotik.db";

    public SendMessage(@NonNull Context appContext, @NonNull WorkerParameters params) {
        super(appContext, params);
    }

    @Nullable
    @Override
    public Object doWork(@NonNull Continuation<? super Result> continuation) {
        Data input= getInputData();
        String message = input.getString("message");
        String number =input.getString("number");
        String host =input.getString("host");
        String personId =input.getString("personId");
        int port = 5038;
        try (Socket socket = new Socket(host, port)) { // Connect to port 5038
            OutputStream output = socket.getOutputStream();
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(output, StandardCharsets.UTF_8));
            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(socket.getInputStream()));

            // Example key-value message
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            String date = new SimpleDateFormat("dd-MM-yyyy", Locale.US).format(new Date());
            String loginMSG = "Action: Login\r\nUsername: apiuser\r\nSecret: apipass\r\n\r\n";
            writer.write(loginMSG);
            writer.flush();
            String line ;
            while ((line = reader.readLine()) != null) {
                if(line.isEmpty()){
                    break;
                }
                Log.d(Tag,line);
            }
            SQLiteDatabase db = SQLiteDatabase.openDatabase(DATABASE_NAME, null, OPEN_READWRITE);
            ContentValues cv = new ContentValues();
            cv.put("content",message);
            cv.put("dateSend",date);
            cv.put("isPinned",false);
            cv.put("read",true);
            cv.put("peerId",personId);
            long id  = db.insert("messages",null,cv);
            String sendCommand = String.format(Locale.US,"Action: smscommand\r\ncommand: gsm send sms 2 %s \"%s\" %d\r\n\r\n",number,encodedMessage,(int)id);
            Log.d(Tag,sendCommand);
            writer.write(sendCommand);
            writer.newLine();
            writer.flush();
            while ((line = reader.readLine()) != null) {
                if(line.isEmpty()){
                   break;
                }
                Log.d(Tag,line);
            }
            writer.close();
            db.close();
            return Result.success();
        } catch (Exception e) {
            Log.d(Tag, e.toString());
            return Result.failure();
        }
    }
}
