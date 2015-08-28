class CollisionPoint{
  
  int x, y, c;
  int w, h; //width, height
  int radius;
  int maxThreshold;
  int minThreshold;
  CollisionPoint(int xPos, int yPos, int radiusValue) {
    x = xPos;
    y = yPos;
    radius = radiusValue;
    c = 0;
    // these variables define the sensitiviy range for the collision point
    minThreshold = radius/10; // you have to have this many motion pixels in range in order to trigger any sort of activation
    maxThreshold = (int) (PI * pow(radius,2)/2); // you have to have this many motion pixels in range for full activation (max amplitude and opacity change)
  }

  void display(){
    if(debugMode){
      ellipse(x, y, radius, radius);  
      stroke(5);
      fill(c);    
    }
  }
  
}
