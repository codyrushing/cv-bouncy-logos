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
Boolean reverseDisplay = true;    // turn to false to not reverse/mirror display image
int displayLoc;   // used to calculate reverse location of a pixel in an array

Boolean isCentered = false;

// Logos
Logo logo_charlie, logo_capA, logo_t, logo_l, logo_a1, logo_a2, logo_s1, logo_s2, logo_i, logo_n;

// individual logo images
ArrayList<Logo> logoComponents = new ArrayList<Logo>();

// logo names, sent Reaktor via OSC
String[] logoComponentNames = {"charlie", "A", "t", "l", "a1", "s1", "s2", "i", "a2", "n"};

// defines what proportion of the screen width the logo should take up (0.9 means the logo will take up 90% of the screen)
float totalLogoWidthFactor = 0.9;
int lettersYOffset, lettersXOffset;

void setup() {

  //println(Capture.list());  //get camera device names current attached to this computer
  
  // this is a multiplier used to scale the logo compnents up or down
  float scaleFactor = 1;
  // this is the "resting" state opacity for the logo components
  int initialOpacity = 75;
  
  // size of the project canvas
  size(displayWidth, displayHeight);  /// change to: (displayWidth, displayHeight, P2D);  --to draw 2D shapes
  smooth();

  //Initialize variable and set IP/ Ports for OSC.
  oscsetup();
  
  // video init
  video = new Capture(this, width, height, cam, 30);  
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width,video.height,RGB);  
  video.start();

  // load the images and pass them into our Logo constructor
  logo_charlie = new Logo( loadImage("charlie.png"), 0, 0, initialOpacity) ;
  logo_capA = new Logo( loadImage("letter-Acap.png"), 0, 0, initialOpacity) ;
  logo_t = new Logo( loadImage("letter-t.png"), 0, 0, initialOpacity) ;
  logo_l = new Logo( loadImage("letter-l.png"), 0, 0, initialOpacity) ;
  logo_a1 = new Logo( loadImage("letter-a.png"), 0, 0, initialOpacity) ;
  logo_a2 = new Logo( loadImage("letter-a.png"), 0, 0, initialOpacity) ;
  logo_s1 = new Logo( loadImage("letter-s.png"), 0, 0, initialOpacity) ;
  logo_s2 = new Logo( loadImage("letter-s.png"), 0, 0, initialOpacity) ;
  logo_i = new Logo( loadImage("letter-i.png"), 0, 0, initialOpacity) ;
  logo_n = new Logo( loadImage("letter-n.png"), 0, 0, initialOpacity) ;
        
  // store Logos in proper order in logoComponents ArrayList
  logoComponents.add(logo_charlie);
  logoComponents.add(logo_capA);
  logoComponents.add(logo_t);
  logoComponents.add(logo_l);
  logoComponents.add(logo_a1);
  logoComponents.add(logo_s1);
  logoComponents.add(logo_s2);
  logoComponents.add(logo_i);
  logoComponents.add(logo_a2);
  logoComponents.add(logo_n);
    
  // start at 0, this will get recalculated in positionLogoComponents()
  lettersXOffset = 0;
  lettersYOffset = getYOffset();
  positionLogoComponents();
 
}

void draw() {

  // define list of motionPoints, which contain int arrays of x and y values
  // used to define positions of movement
  ArrayList<int[]> motionPoints = new ArrayList<int[]>();
  
  // Atlassian gray for background
  background(245);

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
  
  // give the camera 30 frames to start up
  // without this, sometimes it will capture a frame before the camera has calibrated itself
  // so that frame will show a large color difference at the very beginning, rendering a lot of motion by mistake 
  if(frameCount > 30){
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
          // add motion pixel to pixels array (native to Processing) that is used to render the motion points to the screen
          pixels[displayLoc] = color(230);     
          // add our new motion point x and y, used to define if motion is happening at our collision point
          motionPoints.add(new int[]{reverseDisplay ? width-x : x,y});                   
        } 
       
      }
    }
  }

  // now that we have all motion points defined, loop through the logo components to determine if motion is happening at any of them
  for(Logo logo : logoComponents){
    CollisionPoint collPoint = logo.collPoint;
    int nearbyMotionPoints = 0;
    boolean isActive = false;
    float magnitude;
    // loop through all of our motion points and see if enough are in our collision point range to trigger activation
    for(int[] motionPoint : motionPoints){
      // if it is in range, add it to our count
      if(dist(collPoint.x, collPoint.y, motionPoint[0], motionPoint[1]) < collPoint.radius){
        nearbyMotionPoints++;
      }
      // if we have surpassed our minimum threshold, some activation will occur
      if(nearbyMotionPoints > collPoint.minThreshold){
       isActive = true;
      } 
      // if we've maxed out, exit the motionPoints loop
      if(nearbyMotionPoints >= collPoint.maxThreshold){
        break;
      }      
    }
    // if activation will occur, scale the magnitude based on the collision point min and max thresholds
    if(isActive){
      magnitude = map(nearbyMotionPoints, collPoint.minThreshold, collPoint.maxThreshold, 0, 1);
      // only activate magnitude is greater than current magnitude (prevents smaller magnitude activations from cancelling larger activations that are still in progress)
      if(logo.magnitude < magnitude){
        logo.activate(magnitude);   
      }
    }
  }  
  
  // render camera output first
  updatePixels();
  // render logo components after camera output so that it sits on top of everything else
  displayLogoComponents();

}

// activates true full screen mode
boolean sketchFullScreen() {
  return true;
}

void positionLogoComponents() {
  int xOffset = lettersXOffset;  
  for(Logo logo : logoComponents){
    if(logo != null){       
      // exceptions     
      if(logo == logo_capA){
        xOffset -= logo_charlie.img.width*0.15;
      }
      else if(logo == logo_t){
        xOffset -= logo_charlie.img.width*0.03;
      } else {
        // default letter spacing
        xOffset += logo_charlie.img.width * 0.05;
      }
            
      logo.x = xOffset;
      logo.y = lettersYOffset + logo_charlie.img.height - logo.img.height;
      logo.transparency = 100;
       
      xOffset += logo.img.width;
      
      logo.genCollPoint();
    }
  }
  
  lettersXOffset = (int) ((width - xOffset)/2);

  // hackish but reliable
  // we need to call positionComponents again after the first call in order to center itself properly
  if(!isCentered){
    isCentered = true;
    scaleLogoComponents(xOffset);
    positionLogoComponents();
  }
    
}


void scaleLogoComponents(int totalLogoWidth) {
  // scale images up or down
  float imgScaleFactor = totalLogoWidthFactor/totalLogoWidth*width;
  for(Logo logo : logoComponents){
    if(logo != null){
      logo.img.resize((int) (logo.img.width * imgScaleFactor), (int) (logo.img.height * imgScaleFactor));
      logo.w = (int) (logo.w * imgScaleFactor);
      logo.h = (int) (logo.h * imgScaleFactor);
    }    
  }
  // reset our x and y offsets after resizing images
  lettersXOffset = (int) (width - totalLogoWidth*imgScaleFactor)/2;
  lettersYOffset = getYOffset();
}

int getYOffset(){
  // TODO, this could be better, manually setting the YOffset for each letter based on charlie
  return (int) (height*.45 - logo_charlie.img.height/2);  
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
