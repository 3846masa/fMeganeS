import java.lang.*;
import java.util.*;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import java.net.URLEncoder;

int REQUEST_CODE = 0;
String resultStr = "";

void action(ArrayList<String> results) {
  if (twitter != null) {
    twitter.shutdown();
    twitter = null;
  }
  if (nico != null) {
    nico.shutdown();
    nico = null;
  }
  if (digiClock != null) {
    digiClock = null;
  }
  if (guide != null) {
    guide = null;
    nextPos = null;
    println("null!");
  }
  if (here != null) {
    here.stop();
    here = null;
  }
  texts = new ArrayList<Text>();
  images = new ArrayList<Image>();
  if (results.contains("天気")) {
    println("weather");
    here = new KetaiLocation(this);
    String placeName = getPrefectural((float)here.getLocation().getLatitude(), (float)here.getLocation().getLongitude());
    WeatherList weatherList = new WeatherList(placeName);
    int dist = -1;
    int placeID = 0;
    for (int i = 0; i < weatherList.getList().size(); i++) {
      Weather weather = weatherList.getList().get(i);
      ketai.sensors.Location loc = new ketai.sensors.Location("place");
      if (dist == -1) {
        dist = int(here.getLocation().distanceTo(loc));
        placeID = i;
      }
      else if (dist > int(here.getLocation().distanceTo(loc))) {
        dist = int(here.getLocation().distanceTo(loc));
        placeID = i;
      }
    }
    Weather weather = weatherList.getList().get(placeID);
    if (results.contains("今日")) {
      weather.setDay(0);
    }
    else if (results.contains("明日")) {
      weather.setDay(1);
    }
    else if (results.contains("あさって") || results.contains("明後日")) {
      weather.setDay(2);
    }
    else if (results.contains("月曜") || results.contains("月曜日")) {
      int day = (7+Calendar.MONDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else if (results.contains("火曜") || results.contains("火曜日")) {
      int day = (7+Calendar.TUESDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else if (results.contains("水曜") || results.contains("水曜日")) {
      int day = (7+Calendar.WEDNESDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else if (results.contains("木曜") || results.contains("木曜日")) {
      int day = (7+Calendar.THURSDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else if (results.contains("金曜") || results.contains("金曜日")) {
      int day = (7+Calendar.FRIDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else if (results.contains("土曜") || results.contains("土曜日")) {
      int day = (7+Calendar.SATURDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else if (results.contains("日曜") || results.contains("日曜日")) {
      int day = (7+Calendar.SUNDAY-Calendar.getInstance().get(Calendar.DAY_OF_WEEK))%7;
      weather.setDay(day);
    }
    else {
      texts.add(new Text("今日から一週間の天気が取得できます。\n例) 「明日の天気」「金曜日の天気」", width*0.1, 0, width*0.8, height*0.8));
      return;
    }
    if (weather.getWeather() != null) {
      texts.add(new Text(weather.getWeather(), 0, 0, width*0.5, height*0.8));
      texts.add(new Text("最高:"+weather.getMaxTemp()+"度/最低:"+weather.getMinTemp()+"度", width*0.5, height*0.5, width*0.5, height*0.4));
      PShape[] weatherShapes = weather.getShapes();
      if (weatherShapes[2] != null) {
        images.add(new Image(weatherShapes[0], width*0.5, height*0.1, width*0.25, height*0.25));
        images.add(new Image(weatherShapes[1], width*0.75, height*0.1, width*0.25, height*0.25));
        images.add(new Image(weatherShapes[2], width*0.625, height*0.35, width*0.25, height*0.25));
      }
      else if (weatherShapes[1] != null) {
        images.add(new Image(weatherShapes[0], width*0.5, height*0.1, width*0.25, height*0.5));
        images.add(new Image(weatherShapes[1], width*0.75, height*0.1, width*0.25, height*0.5));
      }
      else {
        images.add(new Image(weatherShapes[0], width*0.5, height*0.1, width*0.5, height*0.5));
      }
    }
    else {
      texts.add(new Text("情報がありません", width*0.1, 0, width*0.8, height*0.8));
    }
  }
  else if ((results.contains("twitter") || results.contains("ツイッター")) && (results.contains("表示") || results.contains("見る") || results.contains("見せる") || results.contains("みる") || results.contains("みせる"))) {
    println("twitter");
    NetworkInfo nInfo = cm.getActiveNetworkInfo();
    if (!(nInfo != null && nInfo.isConnected() && nInfo.getTypeName().equals("WIFI"))) {
      texts.add(new Text("WIFI環境でのみ見ることができます。", width*0.1, 0, width*0.8, height*0.8));
      return;
    }
    if (hashTag.getText().toString().equals("") || oAuthAccessToken.equals("") || oAuthAccessTokenSecret.equals("")) {
      texts.add(new Text("Twitterの設定をしてください。\n「設定」というと開きます。", width*0.1, 0, width*0.8, height*0.8));
    }
    else {
      twitter = new Twitter(hashTag.getText().toString(), width, height*0.8, oAuthAccessToken, oAuthAccessTokenSecret);
    }
  }
  else if ((results.contains("実況") || results.contains("コメント")) && (results.contains("表示") || results.contains("見る") || results.contains("見せる") || results.contains("みる") || results.contains("みせる"))) {
    println("nicoJikkyo");
    NetworkInfo nInfo = cm.getActiveNetworkInfo();
    if (!(nInfo != null && nInfo.isConnected() && nInfo.getTypeName().equals("WIFI"))) {
      texts.add(new Text("WIFI環境でのみ見ることができます。", width*0.1, 0, width*0.8, height*0.8));
      return;
    }
    if (results.contains("nhk")) {
      nico = new NicoJikkyo(1, width, height*0.8);
    }
    else if (results.contains("いい") && (results.contains("てれ") || results.contains("テレ"))) {
      nico = new NicoJikkyo(2, width, height*0.8);
    }
    else if (results.contains("日テレ") || (results.contains("日本") && results.contains("テレビ"))) {
      nico = new NicoJikkyo(4, width, height*0.8);
    }
    else if (results.contains("テレ朝") || (results.contains("テレビ") && results.contains("朝日"))) {
      nico = new NicoJikkyo(5, width, height*0.8);
    }
    else if (results.contains("tbs")) {
      nico = new NicoJikkyo(6, width, height*0.8);
    }
    else if (results.contains("テレ東") || (results.contains("テレビ") && results.contains("東京"))) {
      nico = new NicoJikkyo(7, width, height*0.8);
    }
    else if (results.contains("フジテレビ")) {
      nico = new NicoJikkyo(8, width, height*0.8);
    }
    else if (results.contains("mx")) {
      nico = new NicoJikkyo(9, width, height*0.8);
    }
    else if (results.contains("テレ玉")) {
      nico = new NicoJikkyo(10, width, height*0.8);
    }
    else if (results.contains("tvk") || (results.contains("テレビ") && results.contains("神奈川"))) {
      nico = new NicoJikkyo(11, width, height*0.8);
    }
    else if ((results.contains("千葉") && results.contains("テレビ"))) {
      nico = new NicoJikkyo(12, width, height*0.8);
    }
    else {
      digiClock = new DigitalClock(0, 0, width, height*0.8);
    }
  }
  else if (results.contains("行く") || ((results.contains("道") || results.contains("行き方")) && results.contains("教える"))) {
    here = new KetaiLocation(this);
    here.start();
    ArrayList<String> places = getPlace(vr.result);
    fill(0);
    rect(0, 0, width, height*0.8);
    fill(255);
    popup = new Text("検索中...", width*0.2, height*0.8, width*0.6, height*0.2);
    popup.show();
    for (String place : places) {
      if (! (place.contains("行き方") || place.contains("道教え"))) {
        searchPlace = place;
        break;
      }
    }
  }
  else if (results.contains("写真") && results.contains("撮る")) {
    fill(0);
    rect(width*0.2, height*0.8, width*0.6, height*0.2);
    fill(255);
    digiClock = new DigitalClock(0, 0, width, height*0.8);
    popup = new Text("写真処理中...", width*0.2, height*0.8, width*0.6, height*0.2);
    popup.show();
    cam.shot();
  }
  else if (results.contains("反転") || results.contains("ミラー")) {
    MIRROR = !MIRROR;
  }
  else if (results.contains("設定")) {
    SETTING_MODE = !SETTING_MODE;
    settings.show();
    drawSettingWindow();
  }
  else {
    println("none");
    digiClock = new DigitalClock(0, 0, width, height*0.8);
  }
}

ArrayList<String> getPlace(String sentence) {
  String query;
  try {
    sentence = URLEncoder.encode(sentence, "UTF-8");
  }
  catch(Exception e) {
    //if error then do here
  }
  String appid = "**PLEASE SET YahooAPI KEY**";
  query = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?";
  query += "appid="+appid+"&";
  query += "sentence="+sentence;
  println(query);
  String[] data = loadStrings(query);
  String str = "";
  for (String get:data) {
    str += get;
  }

  println(str);
  int cursol = 0;
  ArrayList<String> results = new ArrayList<String>();
  while (str.indexOf ("<Keyphrase>", cursol) > 0) {
    cursol = str.indexOf("<Keyphrase>", cursol)+"<Keyphrase>".length();
    results.add(str.substring(cursol, str.indexOf("</Keyphrase>", cursol)));
    cursol = str.indexOf("</Keyphrase>", cursol)+"</Keyphrase>".length();
  }

  return results;
}

ArrayList<String> getPhares(String sentence) {
  String query;
  String appid = "**PLEASE SET YahooAPI KEY**";
  //String sentence = "明治大学中野キャンパスにはどういくの";
  String filter = "1|2|3|4|5|6|7|8|9|10|11|12|13";
  String response = "surface,reading,pos,baseform";
  try {
    sentence = URLEncoder.encode(sentence, "UTF-8");
    filter = URLEncoder.encode(filter, "UTF-8");
    response = URLEncoder.encode(response, "UTF-8");
  }
  catch(Exception e) {
    //if error then do here
  }
  println(sentence);

  query = "http://jlp.yahooapis.jp/MAService/V1/parse?";
  query += "appid="+appid+"&";
  query += "filter="+filter+"&";
  query += "sentence="+sentence+"&";
  query += "response="+response;
  println(query);
  String[] parse = loadStrings(query);
  String str = "";
  for (String get:parse) {
    println(get);
    str += get;
  }

  int cursol = 0;
  XML xml = new XML(str);
  ArrayList<String> results = new ArrayList<String>();
  while (xml.hasNextTag ("word")) {
    XML item = new XML(xml.getNext("word"));
    String word, type;
    String[] data;
    word = item.getNext("surface");
    type = item.getNext("pos");
    if (item.hasNextTag("baseform")) {
      word = item.getNext("baseform");
    }
    results.add(word);
  }

  return results;
}

class XML {
  String xml;
  int cursol;

  XML(String _xml) {
    xml = _xml;
    cursol = 0;
  }

  String getNext(String tag) {
    String item;
    cursol = xml.indexOf("<"+tag+">", cursol)+("<"+tag+">").length();
    item = xml.substring(cursol, xml.indexOf("</"+tag+">", cursol));
    cursol = xml.indexOf("</"+tag+">", cursol)+("</"+tag+">").length();
    return item;
  }

  boolean hasNextTag(String tag) {
    if (xml.indexOf ("<"+tag+">", cursol) > 0) {
      return true;
    }
    return false;
  }

  void setCursol(int _cursol) {
    cursol = _cursol;
  }
}
