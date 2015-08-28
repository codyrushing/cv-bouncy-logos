import oscP5.*;
import netP5.*;

OscP5 oscP5;
String IP="127.0.0.1";
int port=10002;

//The following variables represent attention, blink and meditation respectively.  
NetAddress myRemoteLocation1;            //Attention
NetAddress myRemoteLocation2;            //Meditation
NetAddress myRemoteLocation3;            //Blink
NetAddress myRemoteLocation4;            //Delta
NetAddress myRemoteLocation5;            //Theta
NetAddress myRemoteLocation6;            //Low Alpha
NetAddress myRemoteLocation7;            //High Alpha
NetAddress myRemoteLocation8;            //Low Beta
NetAddress myRemoteLocation9;            //High Beta
NetAddress myRemoteLocation10;           //Low Gamma
NetAddress myRemoteLocation11;           //Mid Gamma


void oscsetup() {
  oscP5 = new OscP5(this,port);
//BTW, Make sure the ports are in the 10000 range.  
  myRemoteLocation1 = new NetAddress(IP,port);
  myRemoteLocation2 = new NetAddress(IP,port);
  myRemoteLocation3 = new NetAddress(IP,port);
  myRemoteLocation4 = new NetAddress(IP,port);
  myRemoteLocation5 = new NetAddress(IP,port);
  myRemoteLocation6 = new NetAddress(IP,port);
  myRemoteLocation7 = new NetAddress(IP,port);
  myRemoteLocation8 = new NetAddress(IP,port);
  myRemoteLocation9 = new NetAddress(IP,port);
  myRemoteLocation10 = new NetAddress(IP,port);
  myRemoteLocation11 = new NetAddress(IP,port);

}

//OSC message send
public void OSC(String name)
{
  OscMessage mymessage = new OscMessage("/"+name);
  mymessage.add (1);
  oscP5.send(mymessage, myRemoteLocation1);
  println(name +1);     
}

public void OSCMagnitude(String name, float magnitude){
  OscMessage mymessage = new OscMessage("/"+name);
  mymessage.add (magnitude);
  oscP5.send(mymessage, myRemoteLocation1);
  println(magnitude);     
}

