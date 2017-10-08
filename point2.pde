import processing.core.PApplet;
import java.util.*;
import java.awt.*;

import processing.sound.*;
SoundFile file;

// when in doubt, consult the Processsing reference: https://processing.org/reference/

/* global variables */
final int margin = 200; //set the margina around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height

Rectangle prev = null;
Rectangle curr = null;
float x1, x2, y1, y2, x, y, deltax, deltay, time;


ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons
int trialNum = 0; //the current trial number (indexes into trials array above)

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks

int ticks = 0;
int red = 0, green = 255, blue = 255; // rgb of the targeted button

Set<Integer> visited = new HashSet<Integer>(); // indicate if the button has been targeted
int numRepeats = 1; //sets the number of times each button repeats in the test

int diffBackground = 0;
int redBG = 0;

int mouseClick = 0;

void setup() 
{
  size(700, 700);
  background(0);
  cursor(CROSS);
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)

  // ===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  //System.out.println("trial order: " + trials);
}

void draw() 
{
  ticks += 1;
  
  if(diffBackground == 0)
  {
    background(0); //set background to black
  }
  else
  {
    diffBackground += 1;
    if(redBG == 1)
      background(255, 0, 0);
    else
      background(0, 255, 0);
    if(diffBackground > 1)
    {
      diffBackground = 0;
    }
  }

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", 
    width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) 
    + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + 
    nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    return; //return, nothing else to do now test is over
  }

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button
   
  /* AI ball */
  if (trialNum < trials.size()) {
    curr = getButtonLocation(trials.get(trialNum));
    x2 = curr.x + curr.width / 2;
    y2 = curr.y + curr.height / 2;
    stroke(255, 69, 0);
        
    if (prev == null || !prev.equals(curr)) {
      if (prev == null) {
        line(0, 0, x2, y2);
      }
      
      if (trialNum >= 1) {
        x1 = prev.x + prev.width / 2;
        y1 = prev.y + prev.height / 2;
 
        float distx = x2 - x1;
        float disty = y2 - y1;
        float divisor = 0.0;
        
        if (Math.abs(distx) >= 200 || Math.abs(disty) >= 200) {
          divisor = 15.0;
        } else if (Math.abs(distx) >= 100 || Math.abs(disty) >= 100) {
          divisor = 8.0;
        } else {
          divisor = 3.0;
        }
        deltax = distx / divisor;
        deltay = disty / divisor;
        x = x1;
        y = y1;
      }
      prev = curr;
    } else {
      line(x1, y1, x2, y2);
      if ((deltax >= 0 && x <= x2 || deltax <= 0 && x >= x2) &&
      (deltay >= 0 && y <= y2 || deltay <= 0 && y >= y2)) {        
        noStroke();
        fill(255, 215, 0);
        ellipse(x, y, 20, 20);
        x += deltax;
        y += deltay;
      }
    }
  }
}

// probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

// you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
  {
    stroke(0, 255, 127); // Set fill to spring green
    if(ticks % 8 == 0)
    {
      fill(0, 0, 0, 0);
      ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
      strokeWeight(5);
      ellipse(bounds.x + bounds.width / 2, 
      bounds.y + bounds.height / 2, bounds.width, bounds.height);  
      // Draw white ellipse using RADIUS mode
    }
    fill(red, green, blue); // if so, fill cyan
    //visited.add(i); // the button has been targeted
    
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
  else
  {
    if (visited.contains(i)) {
      
      noStroke();
      fill(47,79,79); // if visited, mark the button to dark grey
      rect(bounds.x, bounds.y, bounds.width, bounds.height);
      stroke(105);
      line(bounds.x, bounds.y, (bounds.x + bounds.width), (bounds.y + bounds.height));
      line((bounds.x + bounds.width), bounds.y, bounds.x, (bounds.y + bounds.height));
    } else {
      noStroke();
      fill(200); // if not, fill light gray
      
      rect(bounds.x, bounds.y, bounds.width, bounds.height);
    }
  }
}

void mouseMoved()
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;
    
  Rectangle bounds = getButtonLocation(trials.get(trialNum));
  
  //System.out.println("mouse: " + mouseX + " " + mouseY);
  //System.out.println("bounds: " + bounds.x + " " + bounds.y);
  
  int delta = 0;
  int deltaX = bounds.width + delta;
  int deltaY = bounds.height + delta;
  if ((mouseX > (bounds.x - deltaX) && mouseX < (bounds.x + bounds.width + deltaX)) && 
      (mouseY > (bounds.y - deltaY) && mouseY < (bounds.y + bounds.height + deltaY)))
  {
    red = 255;
    green = 0;
    blue = 0;
  } else {
    red = 0;
    green = 255;
    blue = 255;
  }
}

void mousePressed() // test to see if hit was in target!
{
  if(mouseClick == 1)
  {
    if (trialNum >= trials.size()) //if task is over, just return
      return;
  
    if (trialNum == 0) //check if first click, if so, start timer
      startTime = millis();
  
    if (trialNum == trials.size() - 1) //check if final click
    {
      finishTime = millis();
    }
  
    Rectangle bounds = getButtonLocation(trials.get(trialNum));
    //diffBackground = 1;
    
    file = new SoundFile(this, "clickSound.mp3");
    file.play();
    
   //check to see if mouse cursor is inside button
    int delta = 25;
    //int deltaX = bounds.width + delta;
    //int deltaY = bounds.height + delta;
    if ((mouseX > (bounds.x - delta) && mouseX < (bounds.x + bounds.width + delta)) && 
        (mouseY > (bounds.y - delta) && mouseY < (bounds.y + bounds.height + delta))) // test to see if hit was within bounds
    {
      //System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
  
      hits++; 
      redBG = 0;
    } 
    else
    {
      //System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
      misses++;
      redBG = 1;
    }
  
    trialNum++; //Increment trial number
  }
}  


void keyPressed() 
{  
  if(mouseClick == 1)
    return;
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));
  //diffBackground = 1;
  
  file = new SoundFile(this, "clickSound.mp3");
  file.play();
  
 //check to see if mouse cursor is inside button
  int delta = 25;
  //int deltaX = bounds.width + delta;
  //int deltaY = bounds.height + delta;
  if ((mouseX > (bounds.x - delta) && mouseX < (bounds.x + bounds.width + delta)) && 
      (mouseY > (bounds.y - delta) && mouseY < (bounds.y + bounds.height + delta))) // test to see if hit was within bounds
  {
    //System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success

    hits++; 
    redBG = 0;
  } 
  else
  {
    //System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
    redBG = 1;
  }

  trialNum++; //Increment trial number

}