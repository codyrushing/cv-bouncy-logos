import processing.video.*;   

//println(Capture.list());  //get camera device names current attached to this computer

// Variable for capture device
Capture video;

// Previous Frame
PImage prevFrame;
// How different must a pixel be to be a "motion" pixel
float colorThreshold = 100;

//define which camera to use
String cam = "FaceTime HD Camera"; 
//String cam = "Logitech Camera";
boolean debugMode = false;

//reverse display image if camera is not displaying correctly mirrored
Boolean reverseDisplay = true;    //turn to false to not reverse/mirror display image
int displayLoc;   //used to calculate reverse location of a pixel in an array

Boolean isCentered = false;

// Logos
Logo logo_charlie, logo_capA, logo_t, logo_l, logo_a1, logo_s1, logo_s2, logo_i;
String[] logoComponentNames = {"charlie", "A", "t", "l", "a1", "s1", "s2", "i"};

// individual logo images
ArrayList<Logo> logoComponents = new ArrayList<Logo>();


int lettersYOffset, lettersXOffset;

void setup() {

  //println(Capture.list());  //get camera device names current attached to this computer

  float scaleFactor = 1.2;
  int initialOpacity = 75;
  
  //size of the project canvas
  size(displayWidth, displayHeight);  /// change to: (displayWidth, displayHeight, P2D);  --to draw 2D shapes
  smooth();

  oscsetup();  //Initialize variable and set IP/ Ports for OSC.
  video = new Capture(this, width, height, cam, 30);
  
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width,video.height,RGB);
  
  video.start();

  // individual letters
  logo_charlie = new Logo( loadImage("hipchat-logo.png"), 0, 0, initialOpacity) ;
  logo_capA = new Logo( loadImage("hipchat-Hcap.png"), 0, 0, initialOpacity) ;
  logo_t = new Logo( loadImage("hipchat-i.png"), 0, 0, initialOpacity) ;
  logo_l = new Logo( loadImage("hipchat-p.png"), 0, 0, initialOpacity) ;
  logo_a1 = new Logo( loadImage("hipchat-C.png"), 0, 0, initialOpacity) ;
  logo_s1 = new Logo( loadImage("hipchat-h.png"), 0, 0, initialOpacity) ;
  logo_s2 = new Logo( loadImage("hipchat-a.png"), 0, 0, initialOpacity) ;
  logo_i = new Logo( loadImage("hipchat-t.png"), 0, 0, initialOpacity) ;
        
  // add them to logoComponent array
  logoComponents.add(logo_charlie);
  logoComponents.add(logo_capA);
  logoComponents.add(logo_t);
  logoComponents.add(logo_l);
  logoComponents.add(logo_a1);
  logoComponents.add(logo_s1);
  logoComponents.add(logo_s2);
  logoComponents.add(logo_i);
  
  
  // scale images up or down
  for(Logo logo : logoComponents){
    if(logo != null){
      logo.img.resize((int) (logo.img.width * scaleFactor), (int) (logo.img.height * scaleFactor));
      logo.w = (int) (logo.w * scaleFactor);
      logo.h = (int) (logo.h * scaleFactor);
    }    
  }
  
  lettersYOffset = (int) (height*.45 - logo_charlie.img.height/2);  
  // cumulative width will be calculated after first draw
  lettersXOffset = 0;
  
  positionLogoComponents();

  video.start();    
 
}

void draw() {

  ArrayList<int[]> motionPoints = new ArrayList<int[]>();
  
  // atlassian gray
  background(245); //set bg color and reset on every frame

  // Capture video
  if (video.available()) {
   
    // Save previous frame for motion detection!!
    // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height);
    prevFrame.updatePixels();
    video.read();
    
  }
  
  
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
          
// Begin loop to walk through every pixel
  
  for (int y = 0; y < video.height; y ++ ) { 
    for (int x = 0; x < video.width; x ++ ) {
     
      int loc1 = x + y * video.width;            // Get 1D pixel location of the current pixel
      
      //calculate mirrored position shoud you need to flip the image for display
      if (reverseDisplay == true){
        displayLoc = video.width-1 - x + y * video.width;  
      } else {
        displayLoc = loc1;
      }
      
     
      // If the color at that pixel has changed and is different by the treshhold value
      //then there is motion at that pixel and color it black
      if (detectMotion(loc1) == true) { 
        // If motion, display black
        pixels[displayLoc] = color(230);     
        
        motionPoints.add(new int[]{width-x,y});
        
           
      } 
     
    }
  }

  for(Logo logo : logoComponents){
    CollisionPoint collPoint = logo.collPoint;
    int nearbyMotionPoints = 0;
    boolean isActive = false;
    float magnitude;
    for(int[] motionPoint : motionPoints){
      if(dist(collPoint.x, collPoint.y, motionPoint[0], motionPoint[1]) < collPoint.radius){
        nearbyMotionPoints++;
      }
      if(nearbyMotionPoints > collPoint.minThreshold){
       isActive = true;
      } 
      if(nearbyMotionPoints >= collPoint.maxThreshold){
        break;
      }      
    }
    if(isActive){
      magnitude = map(nearbyMotionPoints, collPoint.minThreshold, collPoint.maxThreshold, 0, 1);
      if(logo.magnitude < magnitude){
        logo.activate(magnitude);   
      }
    }
  }  
  
  // render camera output
  updatePixels();
  // render logo
  displayLogoComponents();


}

boolean sketchFullScreen() {
  return true;
}

void positionLogoComponents() {
  // draw charlie to screen
  int xOffset = lettersXOffset;  
  for(Logo logo : logoComponents){
    if(logo != null){ 
      int yOffset = 0;
      // exceptions     
      if(logo == logo_charlie){
        yOffset = logo_charlie.img.height/6;
      }
      // cap H
      else if(logo == logo_capA){
        xOffset += logo_charlie.img.width * 0.13;
      }
      // p
      else if(logo == logo_l){
        xOffset += logo_charlie.img.width * 0.07;
        yOffset = (int) (logo_charlie.img.height/4.2);
      }
      else {
        // default letter spacing
        xOffset += logo_charlie.img.width * 0.075;
      }
            
      logo.x = xOffset;
      logo.y = lettersYOffset + yOffset + logo_charlie.img.height - logo.img.height;
      logo.transparency = 100;
       
      xOffset += logo.img.width;
      
      logo.genCollPoint();
    }
  }
  
  if(lettersXOffset == 0){
    lettersXOffset = (int) ((width - xOffset)/2);
  }

  if(!isCentered){
    isCentered = true;
    positionLogoComponents();
  }
    
}

void displayLogoComponents() {
    for(Logo logo : logoComponents){
      logo.display();
    }
}

//function used to determine motion an a pixels 1D position passed into iprot from an image
boolean detectMotion(int pixelLoc) {

  color current = video.pixels[pixelLoc];      // what is the current color
  color previous = prevFrame.pixels[pixelLoc]; // what is the previous color
        
  // compare colors (previous vs. current)
  float r1 = red(current); float g1 = green(current); float b1 = blue(current);
  float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
  float diff = dist(r1,g1,b1,r2,g2,b2);
  
  return diff > colorThreshold; //returns true if diff bigger than treshhold 
}
