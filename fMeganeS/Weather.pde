class Weather {
  int day=0; // 0:今日, 1:明日, 2:明後日
  String lng;//GPS情報
  String lat;//GPS情報
  String [] weather = new String [7];//天気
  PShape [][] weatherShape = new PShape [7][3];//天気アイコン
  String [] img = new String [7];
  String [] minCelsius = new String [7];//最低気温
  String [] maxCelsius = new String [7];//最高気温

  Weather(String str) {
    loadWeathers(str);
  }

  Weather setDay(int _day) {
    day=_day; // どの日のデータを取得するか決める
    return this;
  }

  void loadWeathers(String _str) {
    String data= _str;//元となるデータ
    int w1, w2;//データ内で何番目にあるか
    String [] numbers;
    String [] values;
    String [] lines = loadStrings("icon.txt");
    numbers = new String [lines.length];
    values = new String [lines.length];
    for ( int i=0 ; i<lines.length ; i++ ) {
      String [] icon = split ( lines[i], "," );
      numbers[i] = icon[0];
      values[i] = icon[1];
    }

    w1=data.indexOf("area id");
    data=data.substring(w1);
    w1=data.indexOf("long");
    w2=data.indexOf("/long");
    lng=data.substring(w1+5, w2-1);
    w1=data.indexOf("lat");
    w2=data.indexOf("/lat");
    lat=data.substring(w1+4, w2-1);
    for (int i=0;i<7;i++) {
      w1=data.indexOf("info");
      data=data.substring(w1);
      w1=data.indexOf("weather");
      w2=data.indexOf("/weather");
      if (w1==-1&&w2==-1) {
        weather[i]="null";
        for (int j=0;j<3;j++) {
          weatherShape[i][j]=null;
        }
        maxCelsius[i]="null";
        minCelsius[i]="null";
      }
      else {
        weather[i]=data.substring(w1+8, w2-1);
        for (int j=0;j<numbers.length;j++) {
          if (numbers[j].equals(weather[i])) {
            img[i]=values[j];
          }
        }
        for (int j=0;j<3;j++) {
          if ((img[i].substring(j, j+1)).equals("1")) {
            weatherShape[i][j]=loadShape("img/Sun.svg");
          } 
          else if ((img[i].substring(j, j+1)).equals("2")) {
            weatherShape[i][j]=loadShape("img/Cloud.svg");
          }  
          else if ((img[i].substring(j, j+1)).equals("3")) {
            weatherShape[i][j]=loadShape("img/Rain.svg");
          } 
          else if ((img[i].substring(j, j+1)).equals("4")) {
            weatherShape[i][j]=loadShape("img/Snow.svg");
          } 
          else if ((img[i].substring(j, j+1)).equals("5")) {
            weatherShape[i][j]=loadShape("img/Lightning.svg");
          } 
          else if ((img[i].substring(j, j+1)).equals("6")) {
            weatherShape[i][j]=loadShape("img/Fog.svg");
          } 
          else {
            weatherShape[i][j]=null;
          }
        }
        w1=data.indexOf("max");
        w2=data.indexOf("/range");
        maxCelsius[i]=data.substring(w1+5, w2-1);
        data=data.substring(w2+7);
        w1=data.indexOf("min");
        w2=data.indexOf("/range");
        minCelsius[i]=data.substring(w1+5, w2-1);
        w1=data.indexOf("/info");
        data=data.substring(w1);
      }
    }
  }

  String getWeather() {
    return weather[day]; // 天気を返す
  }

  String getMinTemp() {
    return minCelsius[day];//最低気温を返す
  }

  String getMaxTemp() {
    return maxCelsius[day];// 最高気温を返す
  }  

  PShape[] getShapes() {
    return weatherShape[day];//天気アイコンを返す
  }

  PShape getShape0() {
    return weatherShape[day][0];//天気アイコンを返す
  }

  PShape getShape1() {
    return weatherShape[day][1];//天気アイコンを返す
  }

  PShape getShape2() {
    return weatherShape[day][2];//天気アイコンを返す
  }
}

class WeatherList {
  ArrayList<Weather> weatherList;
  WeatherList(String cityID) {
    String [] lines2 = loadStrings("prefectural.txt");
    for (int j=0;j<lines2.length;j++) {
      if (lines2[j].equals(cityID)) {
        cityID = String.format("%02d", j+1);
      }
    }
    weatherList = new ArrayList<Weather>();
    String[] weather_data = loadStrings("http://www.drk7.jp/weather/xml/"+cityID+".xml");
    String data = "";
    for (String str:weather_data) {
      data += (decode(str));
    }
    int point=0;
    String area="";
    while (data.indexOf ("<area", point)>0) {
      point = data.indexOf ("<area", point);
      area = data.substring(point, data.indexOf("</area>", point)+("</area>").length());
      weatherList.add(new Weather(area));
      point = data.indexOf("</area>", point)+("</area>").length();
    }
  }

  ArrayList<Weather> getList() {
    return weatherList;
  }
}

String decode(String unicodeLine) {
  String returnText = "";
  String[] splitText = unicodeLine.replaceAll("\\\\u([0-9a-fA-F]{4})", "\n$1\n").split("\n");

  for (String str:splitText) {
    if (str.matches("^[0-9a-fA-F]{4}$")) {
      returnText += new String(new int[] {
        Integer.parseInt(str, 16)
      }
      , 0, 1);
    }
    else {
      returnText += str;
    }
  }
  return returnText;
}

String unidecode(String str1, String str2) {
  return new String(new int[] {
    Integer.parseInt(str1, 16), Integer.parseInt(str2, 16)
  }
  , 0, 2);
}

String getPrefectural(float _lat, float _lng){
  String prefectural = "";
  processing.data.XML geocoding = loadXML("http://maps.googleapis.com/maps/api/geocode/xml?latlng="+_lat+","+_lng+"&sensor=true&language=ja"); 
  for(processing.data.XML data : geocoding.getChildren("result")){
    for(processing.data.XML type : data.getChildren("type")){
      if (type.getContent().equals("administrative_area_level_1")) {
        for(processing.data.XML child : data.getChildren("address_component")) {
          for(processing.data.XML type2 : child.getChildren("type")){
            if (type2.getContent().equals("administrative_area_level_1")) {
              prefectural = child.getChild("long_name").getContent();
            }
          } 
        }
      }
    }
  }
  return prefectural;
}
