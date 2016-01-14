import java.net.URLEncoder;
import java.net.*;

import ketai.sensors.*; 

String str="";

class Guide { 
  ArrayList<Float> lat; // 緯度群
  ArrayList<Float> lng; // 経度群
  ArrayList<String> guide; // 道案内の文章 例)横断歩道を渡る
  ArrayList<String> instructions;
  ArrayList<String> polyline;
  float startLat; // スタート地点の緯度
  float startLng; // スタート地点の経度
  String goal; // ゴール地点の名称
  String goalen; //エンコードしたゴール地点のURL
  String copyright;
  String soujikan;
  int stepCount; // ステップ数
  boolean successful;

  Guide(float _startLat, float _startLng, String _goal) {
    startLat = _startLat;
    startLng = _startLng;
    stepCount = 0;
    goal = _goal;
    String str = "";
    try { 
      goalen  = URLEncoder.encode(goal, "UTF-8");
      String url = "http://maps.googleapis.com/maps/api/directions/xml?language=ja&origin=" + startLat + "," + startLng + "&destination=" + goalen + "&mode=walking&sensor=true";
      println(url);
      String[] steps = loadStrings(url);
      for (String step:steps) {
        str += step;
      }
    }
    catch (Exception e) {
    }
    if (str.indexOf("<step>") >= 0) {
      getInstructions(str);
      successful = true;
    } else {
      successful = false;
    }
  }

  void getInstructions(String str) {
    lat = new ArrayList<Float>();
    int count = str.indexOf("<step>")+6;
    String LAT = str.substring(str.indexOf("<lat>", count)+5, str.indexOf("</lat>", count));
    lat.add(new Float (LAT));
    while (true) {
      if (str.indexOf("<step>", count) < 0) {
        break;
      }
      count = str.indexOf("<end_location>", count);
      count = str.indexOf("<lat>", count)+5;
      lat.add(new Float (str.substring(count, str.indexOf("</lat>", count))));
      count = str.indexOf("<step>", count)+6;
      delay(1);
    }
    lat.remove(0);

    lng = new ArrayList<Float>();
    int count2 = str.indexOf("<step>")+6;
    String LNG = str.substring(str.indexOf("<lng>", count2)+5, str.indexOf("</lng>", count2));
    lng.add(new Float (LNG));
    while (true) {
      if (str.indexOf("<step>", count2) < 0) {
        break;
      }
      count2 = str.indexOf("<end_location>", count2);
      count2 = str.indexOf("<lng>", count2)+5;
      lng.add(new Float (str.substring(count2, str.indexOf("</lng>", count2))));
      count2 = str.indexOf("<step>", count2)+6;
      delay(1);
    }
    lng.remove(0);

    instructions = new ArrayList<String>();
    int count3 = str.indexOf("<step>")+6;
    while (true) {
      if (str.indexOf("<html_instructions>", count3) < 0) {
        break;
      }
      count3 = str.indexOf("<html_instructions>", count3)+19;
      instructions.add(str.substring(count3, str.indexOf("</html_instructions>", count3)).replaceAll("&.*?;.*?&.*?;", ""));
      count3 = str.indexOf("</html_instructions>", count3)+20;
      delay(1);
    }

    polyline = new ArrayList<String>();
    int count4 = str.indexOf("<step>")+6;
    while (true) {
      if (str.indexOf("<polyline>", count4) < 0) {
        break;
      }
      count4 = str.indexOf("<points>", count4)+8;
      polyline.add(str.substring(count4, str.indexOf("</points>", count4)));
      count4 = str.indexOf("</points>", count4)+9;
      delay(1);
    }

    /*
    for (int i = 0; i<lat.size(); ++i) {
     println("lat "+ i + " : " + lat.get(i));
     }
     for (int i = 0; i<lng.size(); ++i) {
     println("lng "+ i + " : " + lng.get(i));
     }
     for (int i = 0; i<instructions.size(); ++i) {
     println("intstruction "+ i + " : " + instructions.get(i));
     }
     for(int i = 0; i<polyline.size(); ++i){
     println("polyline "+ i + " : " + polyline.get(i));
     }
     */

    count3 = str.indexOf("</step>", count3);
    count3 = str.indexOf("<duration>", count3);
    soujikan = str.substring(str.indexOf("<text>", count3)+6, str.indexOf("</text>", count3));
    //println("総時間 : " + soujikan);
    
    goal = str.substring(str.indexOf("<end_address>", count3)+13, str.indexOf("</end_address>", count3));

    copyright = str.substring(str.indexOf("<copyrights>")+12, str.indexOf("</copyrights>"));
    //println("copyrights : " + copyright);
  }

  boolean hasNext() {
    if (lat.size() > stepCount) {
      return true;
    }
    return false;
  }

  GPS next() {
    GPS gps = new GPS(lat.get(stepCount), lng.get(stepCount), instructions.get(stepCount), polyline.get(stepCount));
    stepCount++;
    return gps;
  }
}

class GPS {
  float lat; 
  float lng; 
  String instruction; 
  String polyline; 
  PImage image;
  ketai.sensors.Location location;

  GPS(float _lat, float _lng, String _instruction, String _polyline) {
    lat = _lat; 
    lng = _lng; 
    instruction = _instruction; 
    polyline = _polyline;
    location = new ketai.sensors.Location("next"); // Example location: the University of Illinois at Chicago
    location.setLatitude(_lat);
    location.setLongitude(_lng);
    getImage(_lat, _lng, _polyline);
  }

  /* 参考: http://hondou.homedns.org/pukiwiki/pukiwiki.php?Java%20Google%20Maps%20%A4%AB%A4%E9%C3%CF%BF%DE%B2%E8%C1%FC%A4%F2%BC%E8%C6%C0%A4%B9%A4%EB */
  void getImage(float _lat, float _lng, String _polyline) {
    try { 
      _polyline = URLEncoder.encode(_polyline, "UTF-8");
    } 
    catch(Exception e) {
    }
    String size = int(width*0.5*0.5)+"x"+int(height*0.8*0.5);
    String addr = "http://maps.googleapis.com/maps/api/staticmap?size="+size+"&sensor=false&scale=2&language=ja&markers=label:P%7Ccolor:yellow%7C"+_lat+","+_lng+"&path=weight:5%7Ccolor:0x0000FFFF%7Cenc:"+_polyline;
    image = loadImage(addr);
  }
}

