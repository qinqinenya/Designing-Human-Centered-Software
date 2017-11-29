import java.util.*;

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
Color[] colors = new Color[28];
Color[] textColors = new Color[26];
boolean[] status = new boolean[28];
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
  
  for (int i = 0; i < 28; i++) {
    colors[i] = new Color(200, 200, 200);
  }
  
  for (int i = 0; i < 26; i++) {
    textColors[i] = new Color(0, 0, 0);
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
    // if input is wrong
    if (currentPhrase.length() < currentTyped.length() || 
            !currentPhrase.substring(0, currentTyped.length()).equals(currentTyped)) {
      background(240,128,128);
      fill(0);
    }
    // if everything is correct
    else if (currentPhrase.length() == currentTyped.length()) {
      background(60,179,113);
      fill(0);
    }
    else {
      fill(128);
    }
    
    int left = 150;
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textSize(30);
    textAlign(LEFT); //align the text left
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, left, 50); //draw the trial count
    fill(255);
    text("Target :   " + currentPhrase, left, 100); //draw the target string
    text("Entered: " + currentTyped + "|", left, 140); //draw what the user has entered thus far
    fill(255, 0, 0);
    rect(800, 800, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 910); //draw next label
    
    
    fill(80); // input keyboard background color
    rect(270, 270, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"
    
    //my draw code
    float firstRowX = keyBoardStartPoint+14;
    float firstRowY = keyBoardStartPoint+50;
    float buttonLen = 35;
    float buttonWid = 70;
    float blankWid = 7;
    float distBetweenButton = buttonLen + blankWid;
    
    fill(colors[16].red, colors[16].green, colors[16].blue);
    rect(firstRowX, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[22].red, colors[22].green, colors[22].blue);
    rect(firstRowX+distBetweenButton*1, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[4].red, colors[4].green, colors[4].blue);
    rect(firstRowX+distBetweenButton*2, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[17].red, colors[17].green, colors[17].blue);
    rect(firstRowX+distBetweenButton*3, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[19].red, colors[19].green, colors[19].blue);
    rect(firstRowX+distBetweenButton*4, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[24].red, colors[24].green, colors[24].blue);
    rect(firstRowX+distBetweenButton*5, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[20].red, colors[20].green, colors[20].blue);
    rect(firstRowX+distBetweenButton*6, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[8].red, colors[8].green, colors[8].blue);
    rect(firstRowX+distBetweenButton*7, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[14].red, colors[14].green, colors[14].blue);
    rect(firstRowX+distBetweenButton*8, firstRowY, buttonLen, buttonWid, 5);
    
    fill(colors[15].red, colors[15].green, colors[15].blue);
    rect(firstRowX+distBetweenButton*9, firstRowY, buttonLen, buttonWid, 5);
    
    
    
    
    float secondRowX = keyBoardStartPoint+34;
    float secondRowY = firstRowY+100;
    
    fill(colors[0].red, colors[0].green, colors[0].blue);
    rect(secondRowX, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[18].red, colors[18].green, colors[18].blue);
    rect(secondRowX+distBetweenButton*1, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[3].red, colors[3].green, colors[3].blue);
    rect(secondRowX+distBetweenButton*2, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[5].red, colors[5].green, colors[5].blue);
    rect(secondRowX+distBetweenButton*3, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[6].red, colors[6].green, colors[6].blue);
    rect(secondRowX+distBetweenButton*4, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[7].red, colors[7].green, colors[7].blue);
    rect(secondRowX+distBetweenButton*5, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[9].red, colors[9].green, colors[9].blue);
    rect(secondRowX+distBetweenButton*6, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[10].red, colors[10].green, colors[10].blue);
    rect(secondRowX+distBetweenButton*7, secondRowY, buttonLen, buttonWid, 5);
    
    fill(colors[11].red, colors[11].green, colors[11].blue);
    rect(secondRowX+distBetweenButton*8, secondRowY, buttonLen, buttonWid, 5);
    
    
    
    
    float thirdRowX = keyBoardStartPoint+75;
    float thirdRowY = secondRowY+100;
    
    fill(colors[25].red, colors[25].green, colors[25].blue);
    rect(thirdRowX, thirdRowY, buttonLen, buttonWid, 5);
    
    fill(colors[23].red, colors[23].green, colors[23].blue);
    rect(thirdRowX+distBetweenButton*1, thirdRowY, buttonLen, buttonWid, 5);
    
    fill(colors[2].red, colors[2].green, colors[2].blue);
    rect(thirdRowX+distBetweenButton*2, thirdRowY, buttonLen, buttonWid, 5);
    
    fill(colors[21].red, colors[21].green, colors[21].blue);
    rect(thirdRowX+distBetweenButton*3, thirdRowY, buttonLen, buttonWid, 5);
    
    fill(colors[1].red, colors[1].green, colors[1].blue);
    rect(thirdRowX+distBetweenButton*4, thirdRowY, buttonLen, buttonWid, 5);
    
    fill(colors[13].red, colors[13].green, colors[13].blue);
    rect(thirdRowX+distBetweenButton*5, thirdRowY, buttonLen, buttonWid, 5);
    
    fill(colors[12].red, colors[12].green, colors[12].blue);
    rect(thirdRowX+distBetweenButton*6, thirdRowY, buttonLen, buttonWid, 5);
    
    
    
    
    // space
    fill(colors[26].red, colors[26].green, colors[26].blue);
    rect(keyBoardStartPoint+90, thirdRowY+100, 180, 50, 5);
    //backspace
    fill(colors[27].red, colors[27].green, colors[27].blue);
    rect(keyBoardStartPoint+290, thirdRowY+100, 60, 50, 5);
    
    
    
    
    textAlign(CENTER);
    textSize(35);
    
    firstRowX += 17;
    firstRowY += 42;
    distBetweenButton = 42;
    
    fill(textColors[16].red, textColors[16].green, textColors[16].blue);
    text("q", firstRowX, firstRowY);
    
    fill(textColors[22].red, textColors[22].green, textColors[22].blue);
    text("w", firstRowX+distBetweenButton*1, firstRowY);
    
    fill(textColors[4].red, textColors[4].green, textColors[4].blue);
    text("e", firstRowX+distBetweenButton*2, firstRowY);
    
    fill(textColors[17].red, textColors[17].green, textColors[17].blue);
    text("r", firstRowX+distBetweenButton*3, firstRowY);
    
    fill(textColors[19].red, textColors[19].green, textColors[19].blue);
    text("t", firstRowX+distBetweenButton*4, firstRowY);
    
    fill(textColors[24].red, textColors[24].green, textColors[24].blue);
    text("y", firstRowX+distBetweenButton*5, firstRowY);
    
    fill(textColors[20].red, textColors[20].green, textColors[20].blue);
    text("u", firstRowX+distBetweenButton*6, firstRowY);
    
    fill(textColors[8].red, textColors[8].green, textColors[8].blue);
    text("i", firstRowX+distBetweenButton*7, firstRowY);
    
    fill(textColors[14].red, textColors[14].green, textColors[14].blue);
    text("o", firstRowX+distBetweenButton*8, firstRowY);
    
    fill(textColors[15].red, textColors[15].green, textColors[15].blue);
    text("p", firstRowX+distBetweenButton*9, firstRowY);
    
    
    
    
    secondRowX += 17;
    secondRowY += 42;
    
    fill(textColors[0].red, textColors[0].green, textColors[0].blue);
    text("a", secondRowX, secondRowY);
    
    fill(textColors[18].red, textColors[18].green, textColors[18].blue);
    text("s", secondRowX+distBetweenButton*1, secondRowY);
    
    fill(textColors[3].red, textColors[3].green, textColors[3].blue);
    text("d", secondRowX+distBetweenButton*2, secondRowY);
    
    fill(textColors[5].red, textColors[5].green, textColors[5].blue);
    text("f", secondRowX+distBetweenButton*3, secondRowY);
    
    fill(textColors[6].red, textColors[6].green, textColors[6].blue);
    text("g", secondRowX+distBetweenButton*4, secondRowY);
    
    fill(textColors[7].red, textColors[7].green, textColors[7].blue);
    text("h", secondRowX+distBetweenButton*5, secondRowY);
    
    fill(textColors[9].red, textColors[9].green, textColors[9].blue);
    text("j", secondRowX+distBetweenButton*6, secondRowY);
    
    fill(textColors[10].red, textColors[10].green, textColors[10].blue);
    text("k", secondRowX+distBetweenButton*7, secondRowY);
    
    fill(textColors[11].red, textColors[11].green, textColors[11].blue);
    text("l", secondRowX+distBetweenButton*8, secondRowY);
    
    
    
    thirdRowX += 17;
    thirdRowY += 42;
    
    fill(textColors[25].red, textColors[25].green, textColors[25].blue);
    text("z", thirdRowX, thirdRowY);
    
    fill(textColors[23].red, textColors[23].green, textColors[23].blue);
    text("x", thirdRowX+distBetweenButton*1, thirdRowY);
    
    fill(textColors[2].red, textColors[2].green, textColors[2].blue);
    text("c", thirdRowX+distBetweenButton*2, thirdRowY);
    
    fill(textColors[21].red, textColors[21].green, textColors[21].blue);
    text("v", thirdRowX+distBetweenButton*3, thirdRowY);
    
    fill(textColors[1].red, textColors[1].green, textColors[1].blue);
    text("b", thirdRowX+distBetweenButton*4, thirdRowY);
    
    fill(textColors[13].red, textColors[13].green, textColors[13].blue);
    text("n", thirdRowX+distBetweenButton*5, thirdRowY);
    
    fill(textColors[12].red, textColors[12].green, textColors[12].blue);
    text("m", thirdRowX+distBetweenButton*6, thirdRowY);
    
    
    // backspace
    fill(0);
    text("\u2190", keyBoardStartPoint+290+30, thirdRowY+95);
    
  }
  
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{  
  if (startTime == 0) {
    return;
  }
  
  // nexts
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
  
  // first row
  float firstRowX = keyBoardStartPoint+14;
  float firstRowY = keyBoardStartPoint+50;
  float buttonLen = 35;
  float buttonWid = 70;
  float blankWid = 7;
  float distBetweenButton = buttonLen + blankWid;
  
  // first row
  if (didMouseClick(firstRowX, firstRowY, buttonLen, buttonWid)) {
    status[16] = true;
    colors[16] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*1, firstRowY, buttonLen, buttonWid)) {
    status[22] = true;
    colors[22] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*2, firstRowY, buttonLen, buttonWid)) {
    status[4] = true;
    colors[4] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*3, firstRowY, buttonLen, buttonWid)) {
    status[17] = true;
    colors[17] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*4, firstRowY, buttonLen, buttonWid)) {
    status[19] = true;
    colors[19] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*5, firstRowY, buttonLen, buttonWid)) {
    status[24] = true;
    colors[24] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*6, firstRowY, buttonLen, buttonWid)) {
    status[20] = true;
    colors[20] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*7, firstRowY, buttonLen, buttonWid)) {
    status[8] = true;
    colors[8] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*8, firstRowY, buttonLen, buttonWid)) {
    status[14] = true;
    colors[14] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(firstRowX+distBetweenButton*9, firstRowY, buttonLen, buttonWid)) {
    status[15] = true;
    colors[15] = new Color(135, 206, 235);
    return;
  }
  
  // second row
  float secondRowX = keyBoardStartPoint+34;
  float secondRowY = firstRowY+100;
  
  if (didMouseClick(secondRowX, secondRowY, buttonLen, buttonWid)) {
    status[0] = true;
    colors[0] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*1, secondRowY, buttonLen, buttonWid)) {
    status[18] = true;
    colors[18] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*2, secondRowY, buttonLen, buttonWid)) {
    status[3] = true;
    colors[3] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*3, secondRowY, buttonLen, buttonWid)) {
    status[5] = true;
    colors[5] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*4, secondRowY, buttonLen, buttonWid)) {
    status[6] = true;
    colors[6] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*5, secondRowY, buttonLen, buttonWid)) {
    status[7] = true;
    colors[7] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*6, secondRowY, buttonLen, buttonWid)) {
    status[9] = true;
    colors[9] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*7, secondRowY, buttonLen, buttonWid)) {
    status[10] = true;
    colors[10] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(secondRowX+distBetweenButton*8, secondRowY, buttonLen, buttonWid)) {
    status[11] = true;
    colors[11] = new Color(135, 206, 235);
    return;
  }
  
  
  float thirdRowX = keyBoardStartPoint+75;
  float thirdRowY = secondRowY+100;
    
  if (didMouseClick(thirdRowX, thirdRowY, buttonLen, buttonWid)) {
    status[25] = true;
    colors[25] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(thirdRowX+distBetweenButton*1, thirdRowY, buttonLen, buttonWid)) {
    status[23] = true;
    colors[23] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(thirdRowX+distBetweenButton*2, thirdRowY, buttonLen, buttonWid)) {
    status[2] = true;
    colors[2] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(thirdRowX+distBetweenButton*3, thirdRowY, buttonLen, buttonWid)) {
    status[21] = true;
    colors[21] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(thirdRowX+distBetweenButton*4, thirdRowY, buttonLen, buttonWid)) {
    status[1] = true;
    colors[1] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(thirdRowX+distBetweenButton*5, thirdRowY, buttonLen, buttonWid)) {
    status[13] = true;
    colors[13] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(thirdRowX+distBetweenButton*6, thirdRowY, buttonLen, buttonWid)) {
    status[12] = true;
    colors[12] = new Color(135, 206, 235);
    return;
  }
  
  
  // last row
  if (didMouseClick(keyBoardStartPoint+90, thirdRowY+100, 180, 50)) {
    status[26] = true;
    colors[26] = new Color(135, 206, 235);
    return;
  }
  if (didMouseClick(keyBoardStartPoint+290, thirdRowY+100, 60, 50)) {
    status[27] = true;
    colors[27] = new Color(135, 206, 235);
    return;
  }
}

void mouseReleased() 
{
  // first row
  if (status[16]) {
    status[16] = false;
    colors[16] = new Color(200, 200, 200);
    currentTyped += "q";
    if (intelligentInput) {
      intelligentNext('q');
    }
    return;
  }
  if (status[22]) {
    status[22] = false;
    colors[22] = new Color(200, 200, 200);
    currentTyped += "w";
    if (intelligentInput) {
      intelligentNext('w');
    }
    return;
  }
  if (status[4]) {
    status[4] = false;
    colors[4] = new Color(200, 200, 200);
    currentTyped += "e";
    if (intelligentInput) {
      intelligentNext('e');
    }
    return;
  }
  if (status[17]) {
    status[17] = false;
    colors[17] = new Color(200, 200, 200);
    currentTyped += "r";
    if (intelligentInput) {
      intelligentNext('r');
    }
    return;
  }
  if (status[19]) {
    status[19] = false;
    colors[19] = new Color(200, 200, 200);
    currentTyped += "t";
    if (intelligentInput) {
      intelligentNext('t');
    }
    return;
  }
  if (status[24]) {
    status[24] = false;
    colors[24] = new Color(200, 200, 200);
    currentTyped += "y";
    if (intelligentInput) {
      intelligentNext('y');
    }
    return;
  }
  if (status[20]) {
    status[20] = false;
    colors[20] = new Color(200, 200, 200);
    currentTyped += "u";
    if (intelligentInput) {
      intelligentNext('u');
    }
    return;
  }
  if (status[8]) {
    status[8] = false;
    colors[8] = new Color(200, 200, 200);
    currentTyped += "i";
    if (intelligentInput) {
      intelligentNext('i');
    }
    return;
  }
  if (status[14]) {
    status[14] = false;
    colors[14] = new Color(200, 200, 200);
    currentTyped += "o";
    if (intelligentInput) {
      intelligentNext('o');
    }
    return;
  }
  if (status[15]) {
    status[15] = false;
    colors[15] = new Color(200, 200, 200);
    currentTyped += "p";
    if (intelligentInput) {
      intelligentNext('p');
    }
    return;
  }
  
  
  // second row
  if (status[0]) {
    status[0] = false;
    colors[0] = new Color(200, 200, 200);
    currentTyped += "a";
    if (intelligentInput) {
      intelligentNext('a');
    }
    return;
  }
  if (status[18]) {
    status[18] = false;
    colors[18] = new Color(200, 200, 200);
    currentTyped += "s";
    if (intelligentInput) {
      intelligentNext('s');
    }
    return;
  }
  if (status[3]) {
    status[3] = false;
    colors[3] = new Color(200, 200, 200);
    currentTyped += "d";
    if (intelligentInput) {
      intelligentNext('d');
    }
    return;
  }
  if (status[5]) {
    status[5] = false;
    colors[5] = new Color(200, 200, 200);
    currentTyped += "f";
    if (intelligentInput) {
      intelligentNext('f');
    }
    return;
  }
  if (status[6]) {
    status[6] = false;
    colors[6] = new Color(200, 200, 200);
    currentTyped += "g";
    if (intelligentInput) {
      intelligentNext('g');
    }
    return;
  }
  if (status[7]) {
    status[7] = false;
    colors[7] = new Color(200, 200, 200);
    currentTyped += "h";
    if (intelligentInput) {
      intelligentNext('h');
    }
    return;
  }
  if (status[9]) {
    status[9] = false;
    colors[9] = new Color(200, 200, 200);
    currentTyped += "j";
    if (intelligentInput) {
      intelligentNext('j');
    }
    return;
  }
  if (status[10]) {
    status[10] = false;
    colors[10] = new Color(200, 200, 200);
    currentTyped += "k";
    if (intelligentInput) {
      intelligentNext('k');
    }
    return;
  }
  if (status[11]) {
    status[11] = false;
    colors[11] = new Color(200, 200, 200);
    currentTyped += "l";
    if (intelligentInput) {
      intelligentNext('l');
    }
    return;
  }
  
  
  
  // third row
  if (status[25]) {
    status[25] = false;
    colors[25] = new Color(200, 200, 200);
    currentTyped += "z";
    if (intelligentInput) {
      intelligentNext('z');
    }
    return;
  }
  if (status[23]) {
    status[23] = false;
    colors[23] = new Color(200, 200, 200);
    currentTyped += "x";
    if (intelligentInput) {
      intelligentNext('x');
    }
    return;
  }
  if (status[2]) {
    status[2] = false;
    colors[2] = new Color(200, 200, 200);
    currentTyped += "c";
    if (intelligentInput) {
      intelligentNext('c');
    }
    return;
  }
  if (status[21]) {
    status[21] = false;
    colors[21] = new Color(200, 200, 200);
    currentTyped += "v";
    if (intelligentInput) {
      intelligentNext('v');
    }
    return;
  }
  if (status[1]) {
    status[1] = false;
    colors[1] = new Color(200, 200, 200);
    currentTyped += "b";
    if (intelligentInput) {
      intelligentNext('b');
    }
    return;
  }
  if (status[13]) {
    status[13] = false;
    colors[13] = new Color(200, 200, 200);
    currentTyped += "n";
    if (intelligentInput) {
      intelligentNext('n');
    }
    return;
  }
  if (status[12]) {
    status[12] = false;
    colors[12] = new Color(200, 200, 200);
    currentTyped += "m";
    if (intelligentInput) {
      intelligentNext('m');
    }
    return;
  }
  
  
  // last row
  if (status[26]) {
    status[26] = false;
    colors[26] = new Color(200, 200, 200);
    currentTyped += " ";
    if (intelligentInput) {
      intelligentNext(' ');
    }
    return;
  }
  if (status[27]) {
    status[27] = false;
    colors[27] = new Color(200, 200, 200);
    if (currentTyped.length() > 0) {
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    }
    if (intelligentInput) {
      intelligentNext('.');
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

// reset the text colors
void resetAllTextColors() {
  for (int i = 0; i < 26; i++) {
    textColors[i] = new Color(0, 0, 0);
  }
}

// show the next possible letters
void show() {
  if (curr != root && curr != null) {
    TrieNode[] next = curr.next;
    for (int i = 0; i < 26; i++) {
      if (next[i] != null) {
        textColors[i] = new Color(255,99,71);
      }
    }
    
    if (curr.word != null) {
      colors[26] = new Color(255,99,71);
    }
  }  
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