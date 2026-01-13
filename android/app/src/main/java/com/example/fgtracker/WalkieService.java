package com.example.fgtracker;
import org.json.JSONObject;
import io.socket.client.IO;
import io.socket.client.Socket;



import android.app.*;
import android.content.Intent;
import android.media.*;
import android.os.*;
import androidx.core.app.NotificationCompat;

import io.socket.client.IO;
import io.socket.client.Socket;

public class WalkieService extends Service {

  public static final String ACTION_START = "WALKIE_START";
  public static final String ACTION_TALK_START = "WALKIE_TALK_START";
  public static final String ACTION_TALK_STOP = "WALKIE_TALK_STOP";

  private AudioRecord audioRecord;
  private AudioTrack audioTrack;
  private Socket socket;

  private boolean isTalking = false;

  private boolean isCaller = false;
  private String myUserId;
  private String remoteUserId;
  private int bufferSize;

  @Override
  public void onCreate() {
    super.onCreate();
    System.out.println("🟢 WalkieService.onCreate()");
//    forceAudioRoute();   // 🔥 ADD THIS
//    startForegroundNotification();
    initAudio();
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    System.out.println("➡️ WalkieService.onStartCommand()");
    if (intent == null) {
      System.out.println("❌ onStartCommand: intent NULL");
      return START_STICKY;
    }

    String action = intent.getAction();
    System.out.println("➡️ onStartCommand action = " + action);

    if (ACTION_START.equals(action)) {
      myUserId = intent.getStringExtra("myUserId");
      remoteUserId = intent.getStringExtra("remoteUserId");
      isCaller = intent.getBooleanExtra("isCaller", false);

      System.out.println("👤 myUserId = " + myUserId);
      System.out.println("🎯 remoteUserId = " + remoteUserId);

      System.out.println("☎️ isCaller = " + isCaller);

      if (!isCaller) {
        startForegroundNotification(); // ✅ Allowed
      }
      
      initSocket();
    }

    if (ACTION_TALK_START.equals(action)) {
      System.out.println("🎤 ACTION_TALK_START received");
      startTalking(); // only caller can talk

    }

    if (ACTION_TALK_STOP.equals(action)) {
      System.out.println("🔇 ACTION_TALK_STOP received");
     stopTalking();
    }

    return START_STICKY;
  }

  private void startForegroundNotification() {
    String channelId = "walkie_fg";

    NotificationChannel channel = new NotificationChannel(
            channelId,
            "Walkie Talkie",
            NotificationManager.IMPORTANCE_LOW
    );

    getSystemService(NotificationManager.class).createNotificationChannel(channel);

    Notification notification = new NotificationCompat.Builder(this, channelId)
            .setContentTitle("Walkie-Talkie Active")
            .setContentText("Listening…")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .build();

    startForeground(1, notification);
  }

  private void initAudio() {
    int sampleRate = 16000;

    bufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
    );

    System.out.println("🎧 Audio bufferSize = " + bufferSize);

    audioRecord = new AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
    );

    audioTrack = new AudioTrack(
            new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            new AudioFormat.Builder()
                    .setSampleRate(sampleRate)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build(),
            bufferSize,
            AudioTrack.MODE_STREAM,
            AudioManager.AUDIO_SESSION_ID_GENERATE
    );

    audioTrack.play();
    System.out.println("🔊 AudioTrack started");
  }

  private void initSocket() {
    try {
      System.out.println("🌐 Connecting socket…");

      IO.Options options = IO.Options.builder()
              .setQuery("userId=" + myUserId)
              .build();




//      socket = IO.socket("http://10.156.216.195:4000/walkie", options);
      socket = IO.socket("http://fgtracker.in:3000/walkie", options);

      socket.on(Socket.EVENT_CONNECT, args -> {
        System.out.println("✅ Socket CONNECTED as " + myUserId);

        if (audioTrack.getPlayState() != AudioTrack.PLAYSTATE_PLAYING) {
          audioTrack.play();
          System.out.println("🔊 AudioTrack PLAYING after socket connect");
        }
      });


      socket.on(Socket.EVENT_CONNECT_ERROR, args ->
              System.out.println("❌ Socket CONNECT ERROR: " + args[0])
      );

      socket.on("walkie_incoming", args -> {
        System.out.println("📢 WALKIE INCOMING from user " + args[0]);
      });

      socket.on("audio_chunk", args -> {
        byte[] pcm = (byte[]) args[0];

        if (audioTrack.getPlayState() != AudioTrack.PLAYSTATE_PLAYING) {
          audioTrack.play();
          System.out.println("⚠️ AudioTrack restarted");
        }

        audioTrack.write(pcm, 0, pcm.length);
        System.out.println("🔊 audio_chunk RECEIVED size=" + pcm.length);
      });


      socket.connect();

    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void startTalking() {
    if (isTalking || socket == null) return;

    System.out.println("🎙️ START TALKING");
    isTalking = true;

    // 🔔 notify receiver (for socket listeners)
    socket.emit("walkie_start", remoteUserId);

    audioRecord.startRecording();

    new Thread(() -> {
      byte[] buffer = new byte[bufferSize];

      while (isTalking) {
        int read = audioRecord.read(buffer, 0, buffer.length);

        if (read > 0) {
          try {
            JSONObject payload = new JSONObject();
            payload.put("toUserId", remoteUserId);
            payload.put("buffer", buffer.clone());

            socket.emit("audio_chunk", payload);

            System.out.println("📤 Sent audio bytes = " + read);
          } catch (Exception e) {
            e.printStackTrace();
          }
        }
      }
    }).start();
  }



  private void forceAudioRoute() {
    AudioManager am = (AudioManager) getSystemService(AUDIO_SERVICE);

    am.setMode(AudioManager.MODE_IN_COMMUNICATION);
    am.setSpeakerphoneOn(true); // OR false for earpiece

    System.out.println("🔊 Audio route forced");
  }

  private void stopTalking() {
    System.out.println("🛑 STOP TALKING");
    isTalking = false;
    audioRecord.stop();
  }

  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }
}
