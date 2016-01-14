import java.net.*;
import java.io.*;

class Client {
  Socket clsocket;
  DataOutputStream out;
  PrintStream outStr;
  DataInputStream in;
  BufferedReader inStr;
  
  Client(Socket socket) {
    clsocket = socket;
  }
  
  Client(PApplet parent, Socket socket) {
    this(socket);
  }
  
  Client(PApplet parent, String host, int port) {
    this(host, port);
  }
  
  Client(String host, int port) {
    try {
      clsocket = new Socket();
      clsocket.connect(new InetSocketAddress(host, port));
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  String ip() {
    return clsocket.getInetAddress().toString();
  }
  
  int available() {
    int available = -1;
    try {
      if (in == null) in = new DataInputStream(clsocket.getInputStream());
      available = in.available();
      //println(in.available());
    } catch (Exception e) {
      e.printStackTrace();
    }
    return available;
  }
  
  int read() {
    int data = -1;
    try {
      if (in == null) in = new DataInputStream(clsocket.getInputStream());
      data = in.readInt();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return data;
  }
  
  char readChar() {
    char data = (char)0;
    try {
      if (in == null) in = new DataInputStream(clsocket.getInputStream());
      data = in.readChar();
      in.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return data;
  }
  
  byte[] readBytes() {
    byte[] data = null;
    try {
      if (in == null) in = new DataInputStream(clsocket.getInputStream());
      int count = in.available();
      data = new byte[count];
      in.read(data);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return data;
  }
  
  int readBytes(byte[] data) {
    int size;
    try {
      if (in == null) in = new DataInputStream(clsocket.getInputStream());
      size = in.read(data);
      return size;
    } catch (Exception e) {
      e.printStackTrace();
    }
    return -1;
  }
  
  String readString() {
    String data = "";
    try {
      if (inStr == null) inStr = new BufferedReader(new InputStreamReader(clsocket.getInputStream()));
      data = inStr.readLine();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return data;
  }
  
  void write(byte[] data) {
    try {
      if (out == null) out = new DataOutputStream(clsocket.getOutputStream());
      out.write(data, 0, data.length);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  void write(int data) {
    try {
      if (out == null) out = new DataOutputStream(clsocket.getOutputStream());
      out.writeInt(data);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  void write(String data) {
    try {
      if (outStr == null) outStr = new PrintStream(clsocket.getOutputStream());
      outStr.print(data);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  void stop() {
    try {
      clsocket.getOutputStream().flush();
      if (out != null) out.close();
      if (in != null) in.close();
      if (inStr != null) inStr.close();
      if (outStr != null) outStr.close();
      clsocket.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
    
}
