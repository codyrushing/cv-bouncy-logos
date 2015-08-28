class Logo{
  
  int x, y;
  float amplitude;
  PImage img;  //image for each logo letter
  int transparency;
  int initialOpacity;
  float magnitude = 0;
  int maxOpacity = 255;
  int maxAmplitude = (int) (displayHeight*0.25);
  int w, h;
  Boolean isOn = false;
  float currMagnitude = 0;
  CollisionPoint collPoint; //collision point for this logo letter 
    
  Logo(PImage imgToDraw, int xPos, int yPos, int logoTint) {
    x = xPos;
    y = yPos;
    amplitude = 0;
    initialOpacity = logoTint;
    transparency = logoTint; //logoTint;
    img = imgToDraw; 
    w = imgToDraw.width;
    h = imgToDraw.height;
  }

  // gets called on every draw, so you won't need to call this anywhere else
  void display(){   

    float rad = radians(frameCount);    
    /*
    if(amplitude > 0){
      amplitude = max(amplitude - 10, 0);        
    }  

    if(transparency > initialTransparency){
      transparency = max(transparency - 8, initialTransparency);  
    }
        
    tint(255, max(transparency, initialTransparency));  // Apply transparency without changing color

    image(img, x, y + (sin(rad*20) * amplitude));
    */
    
    tint(255, map(magnitude, 0, 1, 255, initialOpacity) );  // Apply transparency without changing color
    image(img, x, y + (sin(rad*20) * map(magnitude, 0, 1, 0, maxAmplitude)));
        
    if(magnitude > 0){
      magnitude = max(magnitude - 0.05, 0);
    }
    
    collPoint.display();
  }
  
  void bounce(float magnitude){
    amplitude = (int) (displayHeight*0.25*magnitude);    
  }
  
  void lightUp(float magnitude){
    transparency = (int) (255*magnitude);
  }
  
  void activate(float mag){
    String name = logoComponentNames[ logoComponents.indexOf(this) ];
    
    magnitude = mag;
    
    OSC(name);
    // OSC magnitude expects 0.25 => 1.0
    OSCMagnitude(name, map(magnitude, 0, 1, 0.25, 1));  
  }
      
  void genCollPoint(){
    collPoint = new CollisionPoint(x+w/2, y+h/2);
  }  
  
}
