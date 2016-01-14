/*
 //-- References 参考文献 --//
 http://wiki.processing.org/w/Android#Mouse.2C_Motion.2C_Keys.2C_and_Input
 http://www.adamrocker.com/blog/261/what-is-the-handler-in-android.html
 //-- References 参考文献 --//
 */

/*-- Libraries ライブラリ群 --*/
//import java.util.ArrayList;
import android.os.Handler;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.physicaloid.lib.usb.*;
import com.physicaloid.lib.*;
import com.physicaloid.lib.usb.driver.uart.*;
import cz.jaybee.intelhex.*;
import com.physicaloid.misc.*;
import com.physicaloid.lib.framework.*;
import com.physicaloid.lib.programmer.avr.*;
import com.physicaloid.lib.fpga.*;
import com.physicaloid.lib.Physicaloid;

import ketai.sensors.*;
/*-- Libraries ライブラリ群 --*/

String touchEvent = ""; // String for touch event type
VoiceRecognizer vr;
Text popup;
ArrayList<Text> texts = new ArrayList<Text>();
ArrayList<Image> images = new ArrayList<Image>();
Handler brightnessHandler = new Handler();
Handler voiceRecognizerHandler = new Handler();
Twitter twitter;
NicoJikkyo nico;
DigitalClock digiClock;
Guide guide;
GPS nextPos;
Text distance;
KetaiLocation here;
Camera cam;
ConnectivityManager cm;
PApplet app = this;
boolean MIRROR = true;
boolean SETTING_MODE = false;

int writeComplete = 0;
boolean wasNetworkConnect = false;
String searchPlace = "";

void setup() {
  orientation(LANDSCAPE);
  textFont(createFont("rounded-l-mplus-1p-thin.ttf", 100));
  background(0);
  Text welcome = new Text("fMeganeS awaken...", 0, 0, width, height);
  welcome.show();

  brightnessHandler.post(new Runnable() {
    public void run() {
      getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
      WindowManager.LayoutParams lp = getWindow().getAttributes();
      lp.screenBrightness = 1.0f;
      getWindow().setAttributes(lp);
      cam = new Camera(app);
    }
  }
  );

  makeSettingsWindow();

  mPhysicaloid = new Physicaloid(this);
  if (mPhysicaloid.open()) {
    writeComplete = 1;
  }

  cm = (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);

  background(0);
  digiClock = new DigitalClock(0, 0, width, height*0.8);
}

void draw() {
  NetworkInfo nInfo = cm.getActiveNetworkInfo();

  if (nInfo == null || !nInfo.isConnected()) {
    wasNetworkConnect = false;
    background(0);
    Text noNet = new Text("インターネットに接続してください", width*0.2, height*0.8, width*0.6, height*0.2);
    noNet.show();
    if (digiClock != null) {
      digiClock = new DigitalClock(0, 0, width, height*0.8);
    }
    digiClock.show();
  } 
  else {
    if (SETTING_MODE == false) {
      settings.hide();
      if (! searchPlace.equals("")) {
        guide = new Guide((float)(here.getLocation().getLatitude()), (float)(here.getLocation().getLongitude()), searchPlace);
        if (guide.successful) {
          nextPos = guide.next();
          distance = new Text("XXXm", width*0.5, height*0.7, width*0.5, height*0.1);
          popup = new Text(searchPlace+"までの案内", width*0.2, height*0.8, width*0.6, height*0.2);
        } 
        else {
          guide = null;
          digiClock = new DigitalClock(0, 0, width, height*0.8);
          popup = new Text(searchPlace+"は見つかりませんでした", width*0.2, height*0.8, width*0.6, height*0.2);
        }
        searchPlace = "";
      }
      background(0);
      /*
      fill(0);
       rect(0, 0, width, height*0.8);
       fill(255);
       */
      if (MIRROR == true) {
        scale(-1, 1);
        translate(-width, 0);
      }

      if (mPhysicaloid.open()) {
        writeComplete = 1;
      }

      String readStr = arduinoRead();
      if (writeComplete == 1) {
        if (readStr.contains("m")==true) {
          cam.shot();
        }
        delay(1);
      }

      if (vr != null && vr.mode == 1) {
        background(0);
        popup = new Text("音声認識中...", width*0.2, height*0.8, width*0.6, height*0.2);
      }
      if (vr != null && vr.mode < 0) {
        background(0);
        popup = new Text("認識失敗", width*0.2, height*0.8, width*0.6, height*0.2);
      }
      if (popup != null) {
        fill(0);
        rect(0, height*0.8, width, height*0.2);
        fill(255);
        popup.show();
      }
      if (digiClock != null) {
        digiClock.show();
      }
      if (twitter != null) {
        twitter.show();
      }
      if (nico != null) {
        nico.show();
      }
      for (Text text : texts) {
        text.show();
      }
      for (Image image : images) {
        image.show();
      }
      if (guide != null) {
        int dist = int(here.getLocation().distanceTo(nextPos.location));
        distance.text = dist+"m";
        distance.show();
        Text instr = new Text(nextPos.instruction, width*0.5, 0, width*0.5, height*0.7);
        instr.show();
        image(nextPos.image, 0, 0, width*0.5, height*0.8);
        if (dist < 10) {
          if (guide.hasNext()) {
            nextPos = guide.next();
          } 
          else {
            action(new ArrayList<String>() {
              { 
                add("時計");
              }
            }
            );
          }
        }
      }
      if (vr != null && vr.result != null) {
        popup = new Text(vr.result, width*0.2, height*0.8, width*0.6, height*0.2);
        background(0);
        println(vr.result);
        ArrayList<String> results = getPhares(vr.result);
        action(results);
        //vr.result = null;
        vr = null;
      }
    }
  }
}

void mousePressed() {
  NetworkInfo nInfo = cm.getActiveNetworkInfo();

  if (nInfo != null && nInfo.isConnected() && SETTING_MODE == false) {
    voiceRecognizerHandler.post(new Runnable() {
      public void run() {
        vr = new VoiceRecognizer();
        vr.startRecognize();
      }
    }
    );
  }
}

public void onBackPressed() {
  //do whatever you want here, or nothing
}

void keyPressed() {
  if (key == CODED && keyCode == MENU && SETTING_MODE == true) {
    keyCode = 1; // don't quit by default
    SETTING_MODE = false;
    settings.hide();
    digiClock = new DigitalClock(0, 0, width, height*0.8);
  }
}

@Override protected void onStop() {
  if (twitter != null) { 
    twitter.shutdown(); 
    twitter = null;
  }
  if (nico != null) { 
    nico.shutdown(); 
    nico = null;
  }
  if (guide != null) { 
    guide = null;
  }
  if (here != null) { 
    here.stop(); 
    here = null;
  }
  if (cam != null) {
    cam.stop();
    cam = null;
  }
  super.onStop();
}

class Image {
  PShape image;
  float x, y, w, h;
  float zoom;

  Image(PShape _image, float _x, float _y, float _w, float _h) {
    image = _image;
    x = _x; 
    y = _y; 
    w = _w; 
    h = _h;
    if ((w/image.width) > (h/image.height)) {
      zoom = h/image.height;
    } 
    else {
      zoom = w/image.width;
    }
  }

  void show() {
    shape(image, x+(w-(image.width*zoom))/2, y+(h-(image.height*zoom))/2, image.width*zoom, image.height*zoom);
  }
}

/*
class Popup {
 int mode;
 String text;
 float fontSize;
 float centerX, centerY;
 float x, y, w, h;
 
 Popup(String _text) {
 this(_text, 0);
 }
 
 Popup(String _text, int _mode) {
 mode = _mode;
 text = _text;
 x = 0; y = 0; w = width; h = height;
 getFitFontSize();
 }
 
 Popup(String _text, int _x, int _y, int _w, int _h) {
 this(_text, 0, (float)_x, (float)_y, (float)_w, (float)_h);
 }
 
 Popup(String _text, float _x, float _y, float _w, float _h) {
 this(_text, 0, _x, _y, _w, _h);
 }
 
 Popup(String _text, int _mode, int _x, int _y, int _w, int _h) {
 this(_text, _mode, (float)_x, (float)_y, (float)_w, (float)_h);
 }
 
 Popup(String _text, int _mode, float _x, float _y, float _w, float _h) {
 mode = _mode;
 text = _text;
 x = _x; y = _y; w = _w; h = _h;
 getFitFontSize();
 }
 
 void show() {
 textAlign(CENTER, CENTER);
 textSize(fontSize);
 text(text, centerX, centerY);
 //println(centerX+"::"+centerY);
 }
 
 void getFitFontSize() {
 fontSize = 1;
 while (true) {
 textSize(fontSize);
 float strWidth = textWidth(text);
 float strHeight = textAscent()+textDescent();
 if (strWidth > w || strHeight > h) {
 centerX = x+(w/2);
 centerY = y+(h-strHeight)/2+textAscent();
 break;
 }
 fontSize+=0.5;
 }
 return;
 }
 }
 */
