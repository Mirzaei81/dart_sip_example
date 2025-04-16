package com.linotik.app;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.os.Bundle;
import android.text.TextPaint;
import android.util.Log;
import android.view.MotionEvent;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.jvtd.flutter_pjsip.PjSipManager;

import io.flutter.embedding.android.FlutterActivity;

public class IncomingCallActivity extends AppCompatActivity {
    private String TAG = "IncomingCall";
    private float startX = 0; // Initial touch position
    private float currentX = 0; // Current finger position
    private PjSipManager instance ;
    @SuppressLint("ClickableViewAccessibility")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getSupportActionBar().hide();
        try {
            instance =  PjSipManager.getInstance();
            instance.libRegThread(Thread.currentThread().getName());
        } catch (Exception e) {
            Log.e(TAG,e.toString());
        }
        setContentView(R.layout.incoming_call_layout);
        Bundle b = getIntent().getExtras();
        TextView textName = findViewById(R.id.name);
        TextView textNumber = findViewById(R.id.number);
        if (b!=null){
            textName.setText(b.getString("name"));
            textName.setText(b.getString("number"));
        }
        TextView rejectText = findViewById(R.id.rejectText);
        LinearLayout reject = findViewById(R.id.reject);
        TextPaint paint =rejectText.getPaint();
        float width = paint.measureText("Slide to Reject");

        Shader textShader=new LinearGradient(0, 0, width, rejectText.getTextSize(),
               new int[]{Color.parseColor("#FFFFFF"),Color.parseColor( "#9B9B9B"),Color.parseColor("#1B73FE")},
                new float[]{0,0.5f, 1}, Shader.TileMode.CLAMP);

        Shader rejecttextShader=new LinearGradient(0, 0, width, rejectText.getTextSize(),
                new int[]{Color.parseColor("#1B73FE"),Color.parseColor( "#9B9B9B"),Color.parseColor("#FFFFFF")},
                new float[]{0,0.5f, 1}, Shader.TileMode.CLAMP);
        rejectText.getPaint().setShader(rejecttextShader);

        TextView answerText = findViewById(R.id.answerText);
        LinearLayout answer= findViewById(R.id.answer);
        LinearLayout answerSlider = findViewById(R.id.answerSlider);
        answerText.getPaint().setShader(textShader);

        answer.setOnTouchListener((v,event)->{
            answerText.setVisibility(VISIBLE);
            rejectText.setVisibility(GONE);
            // Capture the initial touch position
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    startX = event.getX();
                    break;
                case MotionEvent.ACTION_MOVE:
                    // Get the current finger position
                    currentX = event.getX();
                    // Move the ImageView horizontally based on finger movement
                    float deltaX = currentX - startX;
                    answerSlider.setTranslationX(answer.getTranslationX() + deltaX);

                    // Update start position for continuous movement
                    startX = currentX;
                    // Check if slider has reached far left
                    if (answerSlider.getTranslationX() > 50) {
                        preformCall(getApplicationContext());
                    }
                    break;

                case MotionEvent.ACTION_UP:
                    // Reset positions after releasing the touch
                    startX = 0;
                    currentX = 0;
                    break;
            }
            return true;
        });
            // handling reject slider
        LinearLayout rejectSlider = findViewById(R.id.rejectSlider);
        reject.setOnTouchListener((v,event)->{
            answerText.setVisibility(GONE);
            rejectText.setVisibility(VISIBLE);
            // Capture the initial touch position
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    startX = event.getX();
                    break;
                case MotionEvent.ACTION_MOVE:
                    // Get the current finger position
                    currentX = event.getX();
                    // Move the ImageView horizontally based on finger movement
                    float deltaX = currentX - startX;
                    rejectSlider.setTranslationX(answer.getTranslationX() + deltaX);

                    // Update start position for continuous movement
                    startX = currentX;
                    // Check if slider has reached far left
                    if (rejectSlider.getTranslationX() < 50) {
                        preformCall(getApplicationContext());
                    }
                    break;

                case MotionEvent.ACTION_UP:
                    // Reset positions after releasing the touch
                    startX = 0;
                    currentX = 0;
                    break;
            }
            return true;
        });

        super.onCreate(savedInstanceState);
        }
    private void preformCall(Context context) {
        Intent intent = new Intent(context,MainActivity.class);
        intent.putExtra("route","/incoming");
        intent.setAction(Intent.ACTION_RUN);
//        context.startActivity(intent);
    }

}
