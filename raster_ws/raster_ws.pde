import frames.timing.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

void setup() {
  //use 2^n to change the dimensions
  size(512, 512, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    @Override
    public void execute() {
      scene.eye().orbit(scene.is2D() ? new Vector(0, 0, 1) :
        yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100);
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow(2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.location converts points from world to frame
  // here we convert v1 to illustrate the idea
  if (debug) {
    pushStyle();
    stroke(255, 255, 0, 125);
    float v1x= (frame.location(v1).x());
    float v1y= (frame.location(v1).y());
    float v2x= (frame.location(v2).x());
    float v2y= (frame.location(v2).y());
    float v3x= (frame.location(v3).x());
    float v3y= (frame.location(v3).y());
    point(0,0);
    int maxx=round(max(v1x,v2x,v3x));
    int maxy=round(max(v1y,v2y,v3y));
    int minx=round(min(v1x,v2x,v3x));
    int miny=round(min(v1y,v2y,v3y));

    for(int x= minx; x<=maxx; x++){
      for(int y= miny; y<=maxy; y++){
        if(isInside(v1x,v1y,v2x,v2y,v3x,v3y,x,y)){
          rect(x, y,1,1);
        }
      }
    }

    popStyle();
  }
}


float edgeFunction(float ax, float ay, float bx, float by, float px, float py) 
{ 
  float ppx=px;
  float ppy=py;
  return ((ppx - ax) * (by - ay) - (ppy - ay) * (bx - ax)); 
}

boolean isInside(float ax, float ay, float bx, float by, float cx, float cy, int px, int py){
  int w1= round(edgeFunction(ax,ay, bx, by, px+0.5, py+0.5)); 
  int w2= round(edgeFunction(bx, by, cx, cy, px+0.5, py+0.5)); 
  int w3= round(edgeFunction(cx, cy, ax,ay, px+0.5, py+0.5));
    
  float a=(w1+w2+w3)/2;  
  float c1=(w1*255/a);
  float c2=(w2*255/a);
  float c3=(w3*255/a);
  stroke(c1,c2,c3,125);
  return (w1 >= 0 && w2 >= 0 && w3 >= 0);
 
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  if(edgeFunction(v1.x(),v1.y(),v2.x(),v2.y(),v3.x(),v3.y())<0){  //orientar
    Vector vtem=new Vector(v2.x(), v2.y());
    v2=new Vector(v3.x(), v3.y());
    v3=new Vector(vtem.x(), vtem.y());
  }
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
}
