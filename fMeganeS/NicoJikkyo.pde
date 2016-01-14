class NicoJikkyo extends CommentBox {
  Client client;
  String url;
  CommentList commentList;
  int channel;

  NicoJikkyo(int _channel, float _w, float _h) {
    super(_w, _h);
    channel = _channel;
    this.width = _w;
    this.height = _h;
    url = "http://jk.nicovideo.jp/api/getflv?v=jk"+channel;
    commentList = new CommentList(this);

    String res = "";
    for (String str : loadStrings(url)) {
      res += str;
    }
    String thread_id = res.substring(
      res.indexOf("thread_id=")+("thread_id=").length(), 
      res.indexOf("&", res.indexOf("thread_id=")+("thread_id=").length()) );
    String addr = res.substring(
      res.indexOf("ms=")+("ms=").length(), 
      res.indexOf("&", res.indexOf("ms=")+("ms=").length()) );
    int port = Integer.parseInt(
      res.substring(
        res.indexOf("ms_port=")+("ms_port=").length(), 
        res.indexOf("&", res.indexOf("ms_port=")+("ms_port=").length()) ));
    client = new Client(addr, port);
    client.write("<thread thread=\""+thread_id+"\" version=\"20061206\" res_from=\"-10\" />\0");
  }

  void show() {
    if (client.available() > 0) {
      String data = "";
      try {
        data = new String(client.readBytes(), "UTF-8");
      }
      catch(Exception e) {
      }
      println(data);
      int cursol = 0;
      while (data.indexOf ("chat", cursol) > 0 && data.indexOf("resultcode") < 0) {
        cursol = data.indexOf("chat", cursol)+("chat").length();
        cursol = data.indexOf(">", cursol)+1;
        if (cursol > 0 && data.indexOf("</chat>", cursol) >= 0) {
          //text(data.substring(cursol,data.indexOf("<",cursol)),0,0);
          String comment = data.substring(cursol, data.indexOf("<", cursol));
          commentList.add(comment);
          cursol = data.indexOf("</chat>", cursol)+("</chat>").length();
        } 
        else {
          break;
        }
      }
    }
    commentList.showAll();
  }
  
  void shutdown() {
    client.stop();
  }
}
