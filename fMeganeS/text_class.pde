class Text {
  String text;
  float size=1;
  float x;
  float y;
  float w;
  float h;
  Text(String t, float ax, float ay, float aw, float ah ) {
    text = t;
    x = ax;
    y = ay;
    w = aw;
    h = ah;
    /*PFont font;// フォント情報を保存する変数
    font = createFont("MS-PGothic", size);
    textFont(font);// 表示するフォントの指定*/
    fitTextSize();
  }


  void show() {
   // noStroke();
    //rect(x, y, w, h);

    fill(255);
    textSize(size);
    textAlign(CENTER,CENTER);//文字を中央に持ってくる
    text(text, x+w/2, y+h/2);
    smooth();
  }

  void fitTextSize() {
    textSize(size);
    while (textWidth (text)<w && textDescent()+textAscent()<h) {
      size++;
      textSize(size);
    } //画面いっぱいに文字を表示する
    size--; //画面より文字がはみ出しそうになったら、文字を画面の大きさに合わせる
  }
}

class DigitalClock extends Text{
 DigitalClock(float x,float y,float w,float h) {
  super(String.format("%02d:%02d",hour(),minute()), x, y, w, h);
 }
 
 void show() {
   this.text = String.format("%02d:%02d",hour(),minute());
   super.show();
 }
}

