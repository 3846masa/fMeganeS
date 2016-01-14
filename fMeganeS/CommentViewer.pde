import java.util.*;
import java.util.concurrent.*;

class CommentBox {
  float height;
  float width;
  int fontSize;
  
  CommentBox(float _w,float _h) {
    fontSize = 1;
    fontSize = int(_h/7*0.8);
    /*while (true) {
      textSize(fontSize);
      if ((textAscent()+textDescent()) >= _h/7) {
        fontSize--;
        break;
      }
      fontSize++;
    }*/
  }
}

class Comment {
  String comment;
  int xpos;
  int ypos;
  float y;
  CommentBox box;

  Comment(String _comment, int _ypos, CommentBox _box) {
    comment = _comment;
    ypos = _ypos;
    box = _box;
    int textHeight = int(textAscent()+textDescent());
    y = ((ypos)%(int(box.height/textHeight)))*textHeight;
  }

  void show(int speed) {
    textAlign(LEFT, TOP);
    text(comment, (box.width-xpos), y);
    xpos += int(textWidth("x")/3);
  }
}

class CommentList {
  List<Comment> commentList;
  CommentBox box;

  CommentList(CommentBox _box) {
    box = _box;
    commentList = new CopyOnWriteArrayList<Comment>();
  }

  void add(String _comment) {
    Iterator<Comment> iter = commentList.iterator();
    ArrayList<Integer> commentOnStart = new ArrayList<Integer>();
    while (iter.hasNext ()) {
      Comment comment = iter.next();
      if (comment.xpos-textWidth(comment.comment)-textWidth("x") < 0) {
        commentOnStart.add(comment.ypos);
      }
    }
    int ypos = 0;
    while (commentOnStart.contains (ypos)) {
      ypos++;
    }
    if (commentList.size() < 8) {
      commentList.add(new Comment(_comment, ypos, box));
    }
  }

  void showAll() {
    textSize(box.fontSize);
    for(Comment comment:commentList){
      comment.show(commentList.size());
      if (comment.xpos-textWidth(comment.comment) > box.width) {
        commentList.remove(comment);
      }
    }
  }
}

