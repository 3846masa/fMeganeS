import java.util.*;
import java.util.concurrent.*;

import apwidgets.*;
import android.text.InputType;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.util.TypedValue;
import android.content.Context;
import android.view.View;
import android.net.Uri;
import android.content.Intent;

APWidgetContainer settings;
int widgetHeight;
List<Text> settingsTexts = new CopyOnWriteArrayList<Text>();
APEditText hashTag;
APButton getPinButton;
APButton logInButton;
APEditText pinCode;
APButton arduinoInstall;
Text progress;

Physicaloid mPhysicaloid;
PhysicaloidFpga mPhysicaloidFpga;
Boards mSelectedBoard;

/* http://techbooster.org/android/mashup/14064/ */


String info = "";
boolean wasPIN = false;
OAuthAuthorization twOauth;

void makeSettingsWindow() {
  widgetHeight = int(height/8);
  textSize(widgetHeight-50);
  float conv = getApplicationContext().getResources().getDisplayMetrics().density;
  println(conv);
  println(textAscent()+textDescent());

  settings = new APWidgetContainer(this);

  settingsTexts.add(new Text("SETTINGS", 0, 0, width, widgetHeight*2));

  settingsTexts.add(new Text("Twitter", width*0.05, widgetHeight*2, width*0.4, widgetHeight));
  settingsTexts.add(new Text("HashTag", width*0.05, widgetHeight*3, width*0.4, widgetHeight));
  settingsTexts.add(new Text("Login", width*0.05, widgetHeight*5, width*0.4, widgetHeight));

  settingsTexts.add(new Text("Arduino", width*0.5, widgetHeight*2, width*0.5, widgetHeight));

  settingsTexts.add(new Text("戻るには、右下の…を押してください。", width*0.5, widgetHeight*6, width*0.5, widgetHeight*2));  

  hashTag = new APEditText(int(width*0.05), widgetHeight*4, int(width*0.4), widgetHeight);
  hashTag.setInputType(1);
  hashTag.setImeOptions(EditorInfo.IME_ACTION_DONE);
  hashTag.setCloseImeOnDone(true);
  hashTag.setTextSize(int((widgetHeight-50)/conv));
  settings.addWidget(hashTag);

  getPinButton = new APButton(int(width*0.05), widgetHeight*6, int(width*0.4), widgetHeight, "GET PIN");
  getPinButton.setTextSize(int((widgetHeight-50)/conv));
  settings.addWidget(getPinButton);

  pinCode = new APEditText(int(width*0.05), widgetHeight*7, int(width*0.2), widgetHeight);
  pinCode.setInputType(1);
  pinCode.setImeOptions(EditorInfo.IME_ACTION_DONE);
  pinCode.setCloseImeOnDone(true);
  pinCode.setTextSize(int((widgetHeight-50)/conv));
  settings.addWidget(pinCode);

  logInButton = new APButton(int(width*0.25), widgetHeight*7, int(width*0.2), widgetHeight, "LOGIN");
  logInButton.setTextSize(int((widgetHeight-50)/conv));
  settings.addWidget(logInButton);

  arduinoInstall = new APButton(int(width*0.55), widgetHeight*3, int(width*0.45), widgetHeight, "INSTALL");
  arduinoInstall.setTextSize(int((widgetHeight-50)/conv));
  settings.addWidget(arduinoInstall);

  settings.hide();
}

void onClickWidget(APWidget widget) {
  if (widget == getPinButton) {
    new Thread( new Runnable() {
      @Override public void run() {
        connectTwitter();
      }
    }
    ).start();
  } 
  else if (widget == logInButton) {
    InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
    imm.toggleSoftInput(InputMethodManager.HIDE_NOT_ALWAYS, 0);
    new Thread( new Runnable() {
      @Override public void run() {
        authPIN();
      }
    }
    ).start();
  } 
  else if (widget == arduinoInstall) {
    installToArduino();
  }
}

void drawSettingWindow() {
  background(0);
  for (Text text : settingsTexts) {
    text.show();
  }
  if (progress != null) {
    progress.show();
  }
}

void installToArduino() {
  Physicaloid.UploadCallBack mUploadCallback = new Physicaloid.UploadCallBack() {

    @Override
      public void onUploading(int value) {
      progress = new Text("Upload:"+value+" %", width*0.55, widgetHeight*4, width*0.45, widgetHeight);
      println("Upload : "+value+" %\n");
      drawSettingWindow();
    }

    @Override
      public void onPreUpload() {
      //background(0);
      //textAlign(LEFT, TOP);
      //text("Upload : Start\n", 0, 0);
    }

    @Override
      public void onPostUpload(boolean success) {
      if (success) {
        //background(0);
        //textAlign(LEFT, TOP);
        progress = new Text("Upload:Successful", width*0.55, widgetHeight*4, width*0.45, widgetHeight);
        //text("Upload : Successful\n", 0, 0);
        println("Upload : Successful\n");
        writeComplete = 1;
        drawSettingWindow();
      } 
      else {
        //background(0);
        //textAlign(LEFT, TOP);
        //text("Upload fail\n", 0, 0);
        progress = new Text("Upload:Faild...", width*0.55, widgetHeight*4, width*0.45, widgetHeight);
        writeComplete = -1;
        drawSettingWindow();
      }
    }

    @Override
      public void onCancel() {
      //background(0);
      //textAlign(LEFT, TOP);
      progress = new Text("Upload:Cancel", width*0.55, widgetHeight*4, width*0.45, widgetHeight);
      //text("Cancel uploading\n", 0, 0);
      writeComplete = -1;
      drawSettingWindow();
    }

    @Override
      public void onError(UploadErrors err) {
      //background(0);
      //textAlign(LEFT, TOP);
      progress = new Text("Error:"+err.toString(), width*0.55, widgetHeight*4, width*0.45, widgetHeight);
      //text("Error:"+err.toString()+"\n", 0, 0);
      writeComplete = -1;
      drawSettingWindow();
    }
  };

  if (mPhysicaloid.open()) {
    writeComplete = 1;
  }
  if (writeComplete == 1) {
    ByteArrayInputStream firmware = new ByteArrayInputStream(loadBytes("firmware.hex"));
    mPhysicaloid.upload(Boards.ARDUINO_UNO, firmware, mUploadCallback);
  } 
  else if (writeComplete == 0) {
    progress = new Text("接続を検知できません", width*0.55, widgetHeight*4, width*0.45, widgetHeight);
  }
  println(writeComplete);
  drawSettingWindow();
}

void connectTwitter() {
  // Oauth認証オブジェクト作成
  twOauth = new OAuthAuthorization(ConfigurationContext.getInstance());
  // Oauth認証オブジェクトにconsumerKeyとconsumerSecretを設定
  twOauth.setOAuthConsumer(oAuthConsumerKey, oAuthConsumerSecret);
  RequestToken twRequestToken;
  // リクエストトークンの作成
  try {
    twRequestToken = twOauth.getOAuthRequestToken();
  } 
  catch (TwitterException e) {
    println(e.toString());
    return;
  }
  String url = twRequestToken.getAuthorizationURL();
  startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
}

void authPIN() {
  if (twOauth == null || pinCode.getText().toString().equals("")) {
    println("Error:not filled");
    return;
  }
  try {
    AccessToken twAccessToken = twOauth.getOAuthAccessToken(pinCode.getText().toString());

    oAuthAccessToken = twAccessToken.getToken();
    oAuthAccessTokenSecret = twAccessToken.getTokenSecret();

    ConfigurationBuilder builder = new ConfigurationBuilder();
    // アプリ固有の情報
    builder.setOAuthConsumerKey(oAuthConsumerKey);
    builder.setOAuthConsumerSecret(oAuthConsumerSecret);
    // アプリ＋ユーザー固有の情報
    builder.setOAuthAccessToken(oAuthAccessToken);
    builder.setOAuthAccessTokenSecret(oAuthAccessTokenSecret);

    twitter4j.Twitter twitter = new TwitterFactory(builder.build()).getInstance();

    String screenName = twitter.getScreenName();
    println(screenName);
    settingsTexts.add(new Text("@"+screenName, width*0.05, widgetHeight*6, width*0.4, widgetHeight*2));
    settings.removeWidget(pinCode);
    settings.removeWidget(logInButton);
    settings.removeWidget(getPinButton);
    drawSettingWindow();
  } 
  catch (TwitterException e) {
    println(e.toString());
    return;
  }
}

