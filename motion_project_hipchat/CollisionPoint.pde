class CollisionPoint{
  
  int x, y, c;
  int w, h; //width, height
  int radius = 90;
  int maxThreshold;
  int minThreshold;
  CollisionPoint(int xPos, int yPos) {
    x = xPos;
    y = yPos;
    c = 0;
    maxThreshold = (int) (PI * pow(radius,2)/2);
    minThreshold = radius/10;
  }

  void display(){
    if(debugMode){
      ellipse(x, y, radius, radius);  
      stroke(5);
      fill(c);    
    }
  }
  
}
