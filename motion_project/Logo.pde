class Logo{
  
  int x, y;
  float amplitude;
  PImage img;  //image for each logo letter
  int transparency;
  int initialOpacity;
  float magnitude = 0;
  int maxOpacity = 255;
  // define max bounce amplitude, based on height
  int maxAmplitude = (int) (height*0.25);
  int w, h;
  CollisionPoint collPoint; 
    
  Logo(PImage imgToDraw, int xPos, int yPos, int logoTint) {
    x = xPos;
    y = yPos;
    amplitude = 0;
    initialOpacity = logoTint;
    img = imgToDraw; 
    w = imgToDraw.width;
    h = imgToDraw.height;
  }

  // gets called on every draw()
  void display(){   
    // generate a radian value based on current frame count (when used with sin() creates time-based oscillation)
    float rad = radians(frameCount);    
    // when magnitude is 0, we are at full opacity.  as magnitude approaches 1, we fade out to our initial opacity that is set in the constructor above
    tint(255, map(magnitude, 0, 1, 255, initialOpacity) );  // Apply transparency without changing color
    // when magnitude is 0, we stay at our y position as defined by positionLogoComponents() in main sketch file
    // as it approaches 1, we start getting oscillation movement
    image(img, x, y + (sin(rad*20) * map(magnitude, 0, 1, 0, maxAmplitude)));
        
    // decrease our magnitude for every draw() cycle so that it will slowly go back to "resting" state
    if(magnitude > 0){
      magnitude = max(magnitude - 0.05, 0);
    }
    
    // redraw our collision point (only in debug mode)
    collPoint.display();
  }
  
  void activate(float mag){
    String name = logoComponentNames[ logoComponents.indexOf(this) ];
    
    // set magnitude, which changes the opacity and y position inside the display() method
    magnitude = mag;
    
    // send data across OSC
    OSC(name);
    // OSC magnitude expects 0.25 => 1.0
    OSCMagnitude(name, map(magnitude, 0, 1, 0.25, 1));  
  }
      
  // collision point is generated after 
  void genCollPoint(){
    // TODO (possibly rethink this)
    // position collpoint at center and calculate a radius based on width and height
    collPoint = new CollisionPoint(x+w/2, y+h/2, (int) (sqrt(h*w)/2));
  }  
  
}
