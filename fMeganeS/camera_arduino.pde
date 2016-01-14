import ketai.camera.*;
import android.os.Environment;
import android.media.MediaScannerConnection;

import android.app.Activity;
import android.os.Bundle;

String arduinoRead() {
  byte[] buf = new byte[256];
  int readSize=0;

  // TODO : read from the device to a buffer and get read size
  readSize = mPhysicaloid.read(buf);

  String str = "";
  if (readSize>0) {
    try {
      str = new String(buf, "UTF-8");
      //println(str);
    } 
    catch (UnsupportedEncodingException e) {
      //str = e.toString();
    }
  }
  return str;
}

class Camera {
  KetaiCamera cam;
  PApplet app;
  Camera(PApplet _app) {
    app = _app;
    cam = new KetaiCamera(app, 1280, 720, 24);
    cam.start();
  }

  void stop() {
    if (cam != null){
      cam.dispose();
      cam = null;
    }
  }

  void shot() {
    if (cam == null) {
      cam = new KetaiCamera(app, 1280, 720, 24);
    };
    cam.start();
    cam.autoSettings();
    delay(500);
    cam.read();
    String fileName = String.format("%04d%02d%02d%02d%02d%02d", year(), month(), day(), hour(), minute(), second())+".jpg";
    File file = new File(Environment.getExternalStorageDirectory().getPath()+"/Pictures/fMeganeS/"+fileName);
    file.getParentFile().mkdir(); // make save folder
    cam.savePhoto(Environment.getExternalStorageDirectory().getPath()+"/Pictures/fMeganeS/"+fileName); // take a picture
    delay(1000);
    fill(0);
    rect(width*0.2, height*0.8, width*0.6, height*0.2);
    fill(255);
    popup = new Text("写真を撮りました", width*0.2, height*0.8, width*0.6, height*0.2);
    String mimeType = "image/jpeg"; // picture's mimeType
    MediaScannerConnection.scanFile(getApplicationContext(), new String[] {file.getPath()}, new String[] {mimeType}, null); // register picture
    //sendBroadcast(new Intent(Intent.ACTION_MEDIA_MOUNTED, Uri.parse("file://" + Environment.getExternalStorageDirectory())));
  }
}

