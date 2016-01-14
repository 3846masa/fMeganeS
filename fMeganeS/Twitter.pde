/* 参照:http://d.hatena.ne.jp/t-horikiri/20120309/1331263948
        http://d.hatena.ne.jp/t-horikiri/20120309/1331263948*/
import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.json.*;
import twitter4j.internal.util.*;
import twitter4j.management.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;
import twitter4j.internal.json.*;

String oAuthConsumerKey = "** PLEASE SET **";
String oAuthConsumerSecret = "** PLEASE SET **";
String oAuthAccessToken = "";
String oAuthAccessTokenSecret = "";

class Twitter extends CommentBox {
  int fontSize;
  CommentList commentList;

  ConfigurationBuilder builder;
  TwitterStream twitterStream;
  // リスナーを作ります
  StatusListener twlistener = new StatusListener() {
    @Override public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
    }
    @Override public void onScrubGeo(long userId, long upToStatusId) {
    }
    @Override public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    }
    @Override public void onStallWarning(StallWarning arg0) {
    }

    @Override public void onStatus(Status status) {
      // ツイートされた時に通知されるようです
      // 今回はコンソールにscreen_nameと内容を出力します
      String comment = status.getText();
      comment = comment.replaceAll("\n","");
      comment = comment.replaceAll("#\\S*","");
      comment = comment.replaceAll("@\\S*","");
      comment = comment.replaceAll("RT\\s+","");
      comment = comment.replaceAll("http://\\S*","");
      commentList.add(comment);
      System.out.println(status.getUser().getScreenName() + " : " + status.getText());
    }

    @Override public void onException(Exception e) {
      // 例外が起こった場合に通知されます
      // 今回はスタックトレースでも出しておきます
      e.printStackTrace();
    }
  };

  Twitter(String _search,float _w, float _h, String _oAuthAccessToken, String _oAuthAccessTokenSecret) {
    super(_w, _h);
    builder = new ConfigurationBuilder();
    // アプリ固有の情報
    builder.setOAuthConsumerKey(oAuthConsumerKey);
    builder.setOAuthConsumerSecret(oAuthConsumerSecret);
    // アプリ＋ユーザー固有の情報
    builder.setOAuthAccessToken(_oAuthAccessToken);
    builder.setOAuthAccessTokenSecret(_oAuthAccessTokenSecret);

    twitterStream = new TwitterStreamFactory(builder.build()).getInstance();
    // リスナーを登録します
    twitterStream.addListener(twlistener);
    // 検索用のフィルターを作ります
    FilterQuery filterQuery = new FilterQuery();
    // 検索する文字列を設定します。 複数設定することも出来て、配列で渡します
    filterQuery.track(new String[] {_search});
    // フィルターします
    twitterStream.filter(filterQuery);

    this.width = _w;
    this.height = _h;
    commentList = new CommentList(this);
  }

  void show() {
    commentList.showAll();
  }

  void shutdown() {
    twitterStream.shutdown();
  }
}
