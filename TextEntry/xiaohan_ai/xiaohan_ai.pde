import java.util.*;

/* 
   middle box, line color are 200;
   side quad color is 130;
   corner box, input keyboard background color is 80;
   
   text color is 255;
   middle box text color is 50;
   
   when clicked, 
   middle box color is fill(135,206,235);
   side quad box color is fill(0,191,255);
   corner box color is fill(30,144,255);
   
   intelligent input color is fill(255,99,71);
   if the input string's length hits the correct length,
   change the background to green (60,179,113);
   if the input string's length goes beyond, 
   change the background to pink (240,128,128); 
   
   q, 0; z, 1; backspace, 2; blank, 3;
   wxy, 4; def, 5; jkl, 6; prs, 7;
   abc, 8; ghi, 9; mno, 10; tuv, 11;
*/

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 441; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
                                      //http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//My variables
float keyBoardStartPoint = 270;
Color[] colors = new Color[12];
Color[] textColors = new Color[26];
boolean[] status = new boolean[12];
float x = keyBoardStartPoint+100;
float boxWidth = sizeOfInputArea/4+10;
TrieNode root = null;
TrieNode curr = null;
boolean intelligentInput = true;
boolean invalidInput = false;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
    
  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1000, 1000); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  //textFont(createFont("Arial", 30)); //set the font to arial 24
  textSize(30);
  noStroke(); //my code doesn't use any strokes.
  
  for (int i = 0; i < 4; i++) {
    colors[i] = new Color(200, 200, 200);
  }
  for (int i = 4; i < 8; i++) {
    colors[i] = new Color(80, 80, 80);
  }
  for (int i = 8; i < 12; i++) {
    colors[i] = new Color(130, 130, 130);
  }
  
  // middle text
  textColors[16] = new Color(50, 50, 50);
  textColors[25] = new Color(50, 50, 50);
  
  // peripheral text
  for (int i = 0; i < 16; i++) {
    textColors[i] = new Color(255, 255, 255);
  }
  
  for (int i = 17; i < 25; i++) {
    textColors[i] = new Color(255, 255, 255);
  }
  
  if (intelligentInput) {
    String[] terms = loadStrings("terms2.txt"); //load the phrase set into memory
    root = buildTrie(terms);
    curr = root;
    //traverse();
  }
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

  if (finishTime!=0)
  {
    int left = 250;
    int lineDist = 40;
    fill(255);
    textAlign(LEFT);
    text("Finished", left, 150);
    text("Total time taken: " + (finishTime - startTime), left, 150+lineDist*1); //output
    text("Total letters entered: " + lettersEnteredTotal, left, 150+lineDist*2); //output
    text("Total letters expected: " + lettersExpectedTotal, left, 150+lineDist*3); //output
    text("Total errors entered: " + errorsTotal, left, 150+lineDist*4); //output
    
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm, left, 150+lineDist*5); //output
    
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    
    text("Freebie errors: " + freebieErrors, left, 150+lineDist*6); //output
    float penalty = max(errorsTotal-freebieErrors,0) * .5f;
    
    text("Penalty: " + penalty, left, 150+lineDist*7);
    text("WPM w/ penalty: " + (wpm-penalty), left, 150+lineDist*8); //yes, minus, becuase higher WPM is better
    return;
  }
  
  fill(80); // input keyboard background color
  rect(270, 270, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(LEFT);
    text("Click to start time!", 250, 100); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    if (currentPhrase.length() < currentTyped.length() || 
            !currentPhrase.substring(0, currentTyped.length()).equals(currentTyped)) {
      background(240,128,128);
      fill(0);
    }else if (currentPhrase.length() == currentTyped.length()) {
      background(60,179,113);
      fill(0);
    }
    else {
      fill(128);
    }
    int left = 150;
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, left, 50); //draw the trial count
    fill(255);
    text("Target :   " + currentPhrase, left, 100); //draw the target string
    text("Entered: " + currentTyped + "|", left, 140); //draw what the user has entered thus far
    fill(255, 0, 0);
    rect(800, 800, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 910); //draw next label

    //my draw code
    // conor boxes
    // left up box
    fill(colors[4].red, colors[4].green, colors[4].blue);
    rect(keyBoardStartPoint, keyBoardStartPoint, 100+boxWidth/2+10, 100+boxWidth/2+10);
    // right up box
    fill(colors[5].red, colors[5].green, colors[5].blue);
    rect(x+boxWidth*3/2+5-10, keyBoardStartPoint, keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10), 100+boxWidth/2+10);
    // right bottom box
    fill(colors[6].red, colors[6].green, colors[6].blue);
    rect(x+boxWidth*3/2+5-10, x+boxWidth*3/2+5-10, 
         keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10), keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10));
    // left bottom box
    fill(colors[7].red, colors[7].green, colors[7].blue);
    rect(keyBoardStartPoint, x+boxWidth*3/2+5-10, 100+boxWidth/2+10, keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10));
    
    // middle boxes
    // space button
    fill(colors[0].red, colors[0].green, colors[0].blue);
    rect(x, x, boxWidth, boxWidth,5);
    // backspace button
    fill(colors[1].red, colors[1].green, colors[1].blue);
    rect(x+boxWidth+5, x, boxWidth, boxWidth,5);
    // e
    fill(colors[2].red, colors[2].green, colors[2].blue);
    rect(x, x+boxWidth+5, boxWidth, boxWidth,5);
    // t
    fill(colors[3].red, colors[3].green, colors[3].blue);
    rect(x+boxWidth+5, x+boxWidth+5, boxWidth, boxWidth,5);
    
    // up two lines
    noStroke();
    fill(colors[8].red, colors[8].green, colors[8].blue);
    quad(x+10, keyBoardStartPoint, x+boxWidth/2+10, x, x+boxWidth*3/2+5-10, x, x+boxWidth*2+5-10, keyBoardStartPoint);
    
    strokeWeight(2);
    stroke(200);
    line(x+10, keyBoardStartPoint, x+boxWidth/2+10, x);
    line(x+boxWidth*2+5-10, keyBoardStartPoint, x+boxWidth*3/2+5-10, x);
    
    // right two lines
    noStroke();
    fill(colors[9].red, colors[9].green, colors[9].blue);
    quad(keyBoardStartPoint+sizeOfInputArea, x+2*boxWidth+5-10, x+2*boxWidth+5, x+boxWidth*3/2+5-10, x+2*boxWidth+5, 
         x+boxWidth/2+10, keyBoardStartPoint+sizeOfInputArea, x+10);
    
    strokeWeight(2);
    stroke(200);
    line(keyBoardStartPoint+sizeOfInputArea, x+10, x+2*boxWidth+5, x+boxWidth/2+10);
    line(keyBoardStartPoint+sizeOfInputArea, x+2*boxWidth+5-10, x+2*boxWidth+5, x+boxWidth*3/2+5-10);
    
    // bottom two lines
    noStroke();
    fill(colors[10].red, colors[10].green, colors[10].blue);
    quad(x+10, keyBoardStartPoint+sizeOfInputArea, x+boxWidth/2+10, x+boxWidth*2+5, x+boxWidth*3/2+5-10, x+boxWidth*2+5, 
         x+2*boxWidth+5-10, keyBoardStartPoint+sizeOfInputArea);
    
    strokeWeight(2);
    stroke(200);
    line(x+10, keyBoardStartPoint+sizeOfInputArea, x+boxWidth/2+10, x+boxWidth*2+5);
    line(x+2*boxWidth+5-10, keyBoardStartPoint+sizeOfInputArea, x+boxWidth*3/2+5-10, x+boxWidth*2+5);
    
    // left two lines
    noStroke();
    fill(colors[11].red, colors[11].green, colors[11].blue);
    quad(keyBoardStartPoint, x+10, x, x+boxWidth/2+10, x, x+boxWidth*3/2+5-10, keyBoardStartPoint, x+2*boxWidth+5-10);
    
    strokeWeight(2);
    stroke(200);
    line(keyBoardStartPoint, x+10, x, x+boxWidth/2+10);
    line(keyBoardStartPoint, x+2*boxWidth+5-10, x, x+boxWidth*3/2+5-10);
    
    noStroke();
    
    textAlign(CENTER);
    textSize(35);
    
    fill(textColors[22].red, textColors[22].green, textColors[22].blue);
    text("w", keyBoardStartPoint+50, keyBoardStartPoint+110);
    fill(textColors[23].red, textColors[23].green, textColors[23].blue);
    text("x", keyBoardStartPoint+50, keyBoardStartPoint+60);
    fill(textColors[24].red, textColors[24].green, textColors[24].blue);
    text("y", keyBoardStartPoint+100, keyBoardStartPoint+60);
    
    fill(textColors[0].red, textColors[0].green, textColors[0].blue);
    text("a", x+boxWidth/2+12, keyBoardStartPoint+60);
    fill(textColors[1].red, textColors[1].green, textColors[1].blue);
    text("b", x+boxWidth+2, keyBoardStartPoint+60);
    fill(textColors[2].red, textColors[2].green, textColors[2].blue);
    text("c", x+boxWidth*3/2+5-12, keyBoardStartPoint+60);
    
    fill(textColors[3].red, textColors[3].green, textColors[3].blue);
    text("d", x+boxWidth*2+5, keyBoardStartPoint+60);
    fill(textColors[4].red, textColors[4].green, textColors[4].blue);
    text("e", x+boxWidth*2+50, keyBoardStartPoint+60);
    fill(textColors[5].red, textColors[5].green, textColors[5].blue);
    text("f", x+boxWidth*2+50, x+10);
    
    fill(textColors[19].red, textColors[19].green, textColors[19].blue);
    text("t", keyBoardStartPoint+50, x+boxWidth/2+30);
    fill(textColors[20].red, textColors[20].green, textColors[20].blue);
    text("u", keyBoardStartPoint+50, x+boxWidth+15);
    fill(textColors[21].red, textColors[21].green, textColors[21].blue);
    text("v", keyBoardStartPoint+50, x+boxWidth*3/2-4);
    
    fill(textColors[6].red, textColors[6].green, textColors[6].blue);
    text("g", x+boxWidth*2+50, x+boxWidth/2+30);
    fill(textColors[7].red, textColors[7].green, textColors[7].blue);
    text("h", x+boxWidth*2+50, x+boxWidth+15);
    fill(textColors[8].red, textColors[8].green, textColors[8].blue);
    text("i", x+boxWidth*2+50, x+boxWidth*3/2-4);
    
    fill(textColors[15].red, textColors[15].green, textColors[15].blue);
    text("p", keyBoardStartPoint+50, x+boxWidth*2+10);
    fill(textColors[17].red, textColors[17].green, textColors[17].blue);
    text("r", keyBoardStartPoint+55, x+boxWidth*2+60);
    fill(textColors[18].red, textColors[18].green, textColors[18].blue);
    text("s", keyBoardStartPoint+100, x+boxWidth*2+60);
    
    fill(textColors[12].red, textColors[12].green, textColors[12].blue);
    text("m", x+boxWidth/2+12, x+boxWidth*2+60);
    fill(textColors[13].red, textColors[13].green, textColors[13].blue);
    text("n", x+boxWidth+2, x+boxWidth*2+60);
    fill(textColors[14].red, textColors[14].green, textColors[14].blue);
    text("o", x+boxWidth*3/2+5-12, x+boxWidth*2+60);
    
    fill(textColors[9].red, textColors[9].green, textColors[9].blue);
    text("j", x+boxWidth*2+50, x+boxWidth*2+10);
    fill(textColors[10].red, textColors[10].green, textColors[10].blue);
    text("k", x+boxWidth*2+50, x+boxWidth*2+60);
    fill(textColors[11].red, textColors[11].green, textColors[11].blue);
    text("l", x+boxWidth*2+5, x+boxWidth*2+60);
    
    // middle box
    fill(textColors[16].red, textColors[16].green, textColors[16].blue);
    text("q", x+boxWidth/2, x+boxWidth/2+10);
    fill(textColors[25].red, textColors[25].green, textColors[25].blue);
    text("z", x+boxWidth*3/2, x+boxWidth/2+10);
    text("\u2190", x+boxWidth/2, x+boxWidth*3/2+10+5);
    //text("t", x+boxWidth*3/2+5, x+boxWidth*3/2+10+5);
    
    textSize(30);
  }
  
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

float orientationCheck(float x1, float y1, float x2, float y2) {
  return (mouseY-y1)*(x2-mouseX)-(y2-mouseY)*(mouseX-x1);
}

boolean didClickSideQuad(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  return (orientationCheck(x1, y1, x2, y2) >= 0) && (orientationCheck(x2, y2, x3, y3) >= 0) &&
  (orientationCheck(x3, y3, x4, y4) >= 0) && (orientationCheck(x4, y4, x1, y1) >= 0);
}


void mousePressed()
{
  colors[3] = new Color(200, 200, 200);
  
  if (startTime == 0) {
    return;
  }
  
  if (didMouseClick(800, 800, 200, 200)) {
    curr = root;
    resetAllTextColors();
    nextTrial(); //if so, advance to next trial
    return;
  }

  //You are allowed to have a next button outside the 2" area
  if (!didMouseClick(keyBoardStartPoint, keyBoardStartPoint, sizeOfInputArea, sizeOfInputArea))
  {
    return;
  }
  
  // middle boxes
  if (didMouseClick(x, x, boxWidth, boxWidth)) {
    status[0] = true;
    colors[0].red = 135;
    colors[0].green = 206;
    colors[0].blue = 235;
    return;
  }
  if (didMouseClick(x+boxWidth+5, x, boxWidth, boxWidth)) {
    status[1] = true;
    colors[1].red = 135;
    colors[1].green = 206;
    colors[1].blue = 235;
    return;
  }
  if (didMouseClick(x, x+boxWidth+5, boxWidth, boxWidth)) {
    status[2] = true;
    colors[2].red = 135;
    colors[2].green = 206;
    colors[2].blue = 235;
    return;
  }
  if (didMouseClick(x+boxWidth+5, x+boxWidth+5, boxWidth, boxWidth)) {
    status[3] = true;
    colors[3].red = 135;
    colors[3].green = 206;
    colors[3].blue = 235;
    return;
  }
  
  // side quad box
  if (didClickSideQuad(x+boxWidth*2+5-10, keyBoardStartPoint, x+boxWidth*3/2+5-10, x, x+boxWidth/2+10, x, x+10, keyBoardStartPoint)) {
    status[8] = true;
    colors[8].red = 0;
    colors[8].green = 191;
    colors[8].blue = 255;
    return;
  }
  if (didClickSideQuad(keyBoardStartPoint+sizeOfInputArea, x+10, keyBoardStartPoint+sizeOfInputArea, x+2*boxWidth+5-10, 
      x+2*boxWidth+5, x+boxWidth*3/2+5-10, x+2*boxWidth+5, x+boxWidth/2+10)) {
    status[9] = true;
    colors[9].red = 0;
    colors[9].green = 191;
    colors[9].blue = 255;
    return;
  }
  if (didClickSideQuad(x+boxWidth*3/2+5-10, x+boxWidth*2+5, x+2*boxWidth+5-10, keyBoardStartPoint+sizeOfInputArea, 
      x+10, keyBoardStartPoint+sizeOfInputArea, x+boxWidth/2+10, x+boxWidth*2+5)) {
    status[10] = true;
    colors[10].red = 0;
    colors[10].green = 191;
    colors[10].blue = 255;
    return;
  }
  if (didClickSideQuad(x, x+boxWidth/2+10, x, x+boxWidth*3/2+5-10, keyBoardStartPoint, x+2*boxWidth+5-10, keyBoardStartPoint, x+10)) {
    status[11] = true;
    colors[11].red = 0;
    colors[11].green = 191;
    colors[11].blue = 255;
    return;
  }
  
  // corner box
    if (didMouseClick(keyBoardStartPoint, keyBoardStartPoint, 100+boxWidth/2+10, 100+boxWidth/2+10)) {
    status[4] = true;
    colors[4].red = 30;
    colors[4].green = 144;
    colors[4].blue = 255;
    return;
  }
  if (didMouseClick(x+boxWidth*3/2+5-10, keyBoardStartPoint, keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10), 100+boxWidth/2+10)) {
    status[5] = true;
    colors[5].red = 30;
    colors[5].green = 144;
    colors[5].blue = 255;
    return;
  }
  if (didMouseClick(x+boxWidth*3/2+5-10, x+boxWidth*3/2+5-10, 
      keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10), keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10))) {
    status[6] = true;
    colors[6].red = 30;
    colors[6].green = 144;
    colors[6].blue = 255;
    return;
  }
  if (didMouseClick(keyBoardStartPoint, x+boxWidth*3/2+5-10, 100+boxWidth/2+10, keyBoardStartPoint+sizeOfInputArea-(x+boxWidth*3/2+5-10))) {
    status[7] = true;
    colors[7].red = 30;
    colors[7].green = 144;
    colors[7].blue = 255;
    return;
  }
}

void mouseReleased() 
{
  // q
  if (status[0]) {
    status[0] = false;
    colors[0].red = 200;
    colors[0].green = 200;
    colors[0].blue = 200;
    currentTyped += "q";
    if (intelligentInput) {
      intelligentNext('q');
    }
    return;
  }
  // z
  if (status[1]) {
    status[1] = false;
    colors[1].red = 200;
    colors[1].green = 200;
    colors[1].blue = 200;
    currentTyped += "z";
    if (intelligentInput) {
      intelligentNext('z');
    }
    return;
  }
  // backspace
  if (status[2]) {
    status[2] = false;
    colors[2].red = 200;
    colors[2].green = 200;
    colors[2].blue = 200;
    if (currentTyped.length() > 0) {
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    }
    if (intelligentInput) {
      intelligentNext('.');
    }
    return;
  }
  // blank
  if (status[3]) {
    status[3] = false;
    colors[3].red = 200;
    colors[3].green = 200;
    colors[3].blue = 200;
    currentTyped += " ";
    if (intelligentInput) {
      intelligentNext(' ');
    }
    return;
  }
  // abc
  if (status[8]) {
    status[8] = false;
    colors[8].red = 130;
    colors[8].green = 130;
    colors[8].blue = 130;
    translate(x+boxWidth+2, keyBoardStartPoint+60);
    float degree = getDegrees(x+boxWidth+2, keyBoardStartPoint+60);
    if ((degree >= 60 && degree <= 120) || (degree >= -120 && degree <= -60)) {
      currentTyped += "b";
      if (intelligentInput) {
        intelligentNext('b');
      }
    } else if ((degree >= -180 && degree < -120) || (degree > 120 && degree <= 180)) {
      currentTyped += "a";
      if (intelligentInput) {
        intelligentNext('a');
      }
    } else {
      currentTyped += "c";
      if (intelligentInput) {
        intelligentNext('c');
      }
    }
    return;
  }
  if (status[9]) {
    status[9] = false;
    colors[9].red = 130;
    colors[9].green = 130;
    colors[9].blue = 130;
    translate(x+boxWidth*2+50, x+boxWidth+8);
    float degree = getDegrees(x+boxWidth*2+50, x+boxWidth+8);
    if ((degree >= -180 && degree <= -120) || (degree >= 120 && degree <= 180) || (degree >= -60 && degree <= 60)) {
      currentTyped += "h";
      if (intelligentInput) {
        intelligentNext('h');
      }
    } else if (degree > -120 && degree < -60) {
      currentTyped += "g";
      if (intelligentInput) {
        intelligentNext('g');
      }
    } else {
      currentTyped += "i";
      if (intelligentInput) {
        intelligentNext('i');
      }
    }
    return;
  }
  if (status[10]) {
    status[10] = false;
    colors[10].red = 130;
    colors[10].green = 130;
    colors[10].blue = 130;
    translate(x+boxWidth+2, x+boxWidth*2+60);
    float degree = getDegrees(x+boxWidth+2, x+boxWidth*2+60);
    if ((degree >= 60 && degree <= 120) || (degree >= -120 && degree <= -60)) {
      currentTyped += "n";
      if (intelligentInput) {
        intelligentNext('n');
      }
    } else if ((degree >= -180 && degree < -120) || (degree > 120 && degree <= 180)) {
      currentTyped += "m";
      if (intelligentInput) {
        intelligentNext('m');
      }
    } else {
      currentTyped += "o";
      if (intelligentInput) {
        intelligentNext('o');
      }
    }
    return;
  }
  if (status[11]) {
    status[11] = false;
    colors[11].red = 130;
    colors[11].green = 130;
    colors[11].blue = 130;
    translate(keyBoardStartPoint+50, x+boxWidth+15);
    float degree = getDegrees(keyBoardStartPoint+50, x+boxWidth+15);
    if ((degree >= -180 && degree <= -120) || (degree >= 120 && degree <= 180) || (degree >= -60 && degree <= 60)) {
      currentTyped += "u";
      if (intelligentInput) {
        intelligentNext('u');
      }
    } else if (degree > -120 && degree < -60) {
      currentTyped += "t";
      if (intelligentInput) {
        intelligentNext('t');
      }
    } else {
      currentTyped += "v";
      if (intelligentInput) {
        intelligentNext('v');
      }
    }
    return;
  }
  if (status[4]) {
    status[4] = false;
    colors[4].red = 80;
    colors[4].green = 80;
    colors[4].blue = 80;
    translate(keyBoardStartPoint+50, keyBoardStartPoint+60);
    float degree = getDegrees(keyBoardStartPoint+50, keyBoardStartPoint+60);
    if ((degree >= -180 && degree <= -90) || (degree >= 30 && degree <= 60)) {
      currentTyped += "x";
      if (intelligentInput) {
        intelligentNext('x');
      }
    } else if (degree > -90 && degree < 30) {
      currentTyped += "y";
      if (intelligentInput) {
        intelligentNext('y');
      }
    } else {
      currentTyped += "w";
      if (intelligentInput) {
        intelligentNext('w');
      }
    }
    return;
  }
  if (status[5]) {
    status[5] = false;
    colors[5].red = 80;
    colors[5].green = 80;
    colors[5].blue = 80;
    translate(x+boxWidth*2+50, keyBoardStartPoint+60);
    float degree = getDegrees(x+boxWidth*2+50, keyBoardStartPoint+60);
    if ((degree >= 120 && degree <= 150) || (degree >= -90 && degree <= 0)) {
      currentTyped += "e";
      if (intelligentInput) {
        intelligentNext('e');
      }
    } else if ((degree > 150 && degree <= 180) || (degree >= -180 && degree < -90)) {
      currentTyped += "d";
      if (intelligentInput) {
        intelligentNext('d');
      }
    } else {
      currentTyped += "f";
      if (intelligentInput) {
        intelligentNext('f');
      }
    }
    return;
  }
  if (status[6]) {
    status[6] = false;
    colors[6].red = 80;
    colors[6].green = 80;
    colors[6].blue = 80;
    translate(x+boxWidth*2+50, x+boxWidth*2+60);
    float degree = getDegrees(x+boxWidth*2+50, x+boxWidth*2+60);
    if ((degree >= -150 && degree <= -120) || (degree >= 0 && degree <= 90)) {
      currentTyped += "k";
      if (intelligentInput) {
        intelligentNext('k');
      }
    } else if ((degree >= -180 && degree < -150) || (degree >= 90 && degree <= 180)) {
      currentTyped += "l";
      if (intelligentInput) {
        intelligentNext('l');
      }
    } else {
      currentTyped += "j";
      if (intelligentInput) {
        intelligentNext('j');
      }
    }
    return;
  }
  if (status[7]) {
    status[7] = false;
    colors[7].red = 80;
    colors[7].green = 80;
    colors[7].blue = 80;
    translate(keyBoardStartPoint+55, x+boxWidth*2+60);
    float degree = getDegrees(keyBoardStartPoint+55, x+boxWidth*2+60);
    if ((degree >= -60 && degree <= -30) || (degree >= 90 && degree <= 180)) {
      currentTyped += "r";
      if (intelligentInput) {
        intelligentNext('r');
      }
    } else if (degree > -30 && degree <= 90) {
      currentTyped += "s";
      if (intelligentInput) {
        intelligentNext('s');
      }
    } else {
      currentTyped += "p";
      if (intelligentInput) {
        intelligentNext('p');
      }
    }
    return;
  }
}

void intelligentNext(char c) {
  resetAllTextColors();
  
  if (curr == null) {
    curr = root;
    return;
  }
  
  if (c == ' ') {
    curr = root;
    show();
    return;
  }
  
  if (c == '.') {
    if (!invalidInput) {
      curr = curr.parent == null ? root: curr.parent;
    } else {
      invalidInput = false;
    }    
    show();
    return;
  }
  
  if (curr.next[c - 'a'] != null) {
    curr = curr.next[c - 'a'];
    show();
    return;
  }
  
  invalidInput = true;
}

void resetAllTextColors() {
  // middle text
  textColors[16] = new Color(50, 50, 50);
  textColors[25] = new Color(50, 50, 50);
  
  // peripheral text
  for (int i = 0; i < 16; i++) {
    textColors[i] = new Color(255, 255, 255);
  }
  
  for (int i = 17; i < 25; i++) {
    textColors[i] = new Color(255, 255, 255);
  }
}

void show() {
  if (curr != root && curr != null) {
    TrieNode[] next = curr.next;
    for (int i = 0; i < 26; i++) {
      if (next[i] != null) {
        textColors[i] = new Color(255,99,71);
      }
    }
    
    if (curr.word != null) {
      colors[3] = new Color(255,99,71);
    }
  }  
}

// always positive.
// close to 90 if it is vertical; 
// close to 180 if it is left horizontal
// close to 0 if it is right horizontal
float getDegrees(float x, float y) {
  return degrees(atan2(mouseY-y, mouseX-x));
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

    if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    System.out.println("Raw WPM: " + wpm); //output
    
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    
    System.out.println("Freebie errors: " + freebieErrors); //output
    float penalty = max(errorsTotal-freebieErrors,0) * .5f;
    
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");
    
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  }
  else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}



//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}

private static class Color {
  int red;
  int green;
  int blue;
  Color (int red, int green, int blue) {
    this.red = red;
    this.green = green;
    this.blue = blue;
  }
}

private TrieNode buildTrie(String[] words) {
    TrieNode root = new TrieNode();
    for (String w : words) {
        TrieNode p = root;
        for (char c : w.toCharArray()) {
            int i = c - 'a';
            if (p.next[i] == null){
                p.next[i] = new TrieNode();
            }
            p.next[i].parent = p;
            p = p.next[i];
       }
       p.word = w;
    }
    return root;
}

//private void traverse () {
//    inOrderHelper(root);
//    System.out.println();
//}

//private void inOrderHelper (TrieNode toVisit) {
//    if(toVisit != null) {
//        System.out.print(toVisit);
//        for (int i = 0; i < toVisit.next.length; i++) {
//            inOrderHelper(toVisit.next[i]);
//        }
//    }
//}

private static class TrieNode {
    TrieNode[] next = new TrieNode[26];
    TrieNode parent;
    String word;
    
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < 26; i++) {
            if (next[i] != null) {
                sb.append((char)('a' + i) + " ");
            }
        }
        if (word != null) {
            sb.append(word);
        }
        sb.append("]");
        return sb.toString();
    }
}