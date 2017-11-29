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
final int DPIofYourDeviceScreen = 441;
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

float boxWidth = sizeOfInputArea/4;
float keyBoardStartPoint = 270;
float horizontalGap = 44.0;//DPIofYourDeviceScreen * (44.0/441.0);
float verticalGap = 48.0;//DPIofYourDeviceScreen * (48.0/441.0);
float horizontalMarginSide = 55.0;//DPIofYourDeviceScreen * (55.0/441.0);
float horizontalMarginTop = 15.0;//DPIofYourDeviceScreen * (15.0/441.0);
float verticalMarginTop = 115.0;//DPIofYourDeviceScreen * (115.0/441.0);
float verticalMarginSide = 15.0;//DPIofYourDeviceScreen * (15.0/441.0);
boolean selectedTopQuad = false;
boolean selectedRightQuad = false;
boolean selectedBottomQuad = false;
boolean selectedLeftQuad = false;
boolean selectedSpace = false;
boolean selectedBackspace = false;
int sectionFill[] = new int[8];
boolean started = false;
Color[] colors = new Color[28];
TrieNode root = null;
TrieNode curr = null;
boolean intelligentInput = true;
boolean invalidInput = false;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
    
  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1000,1000);//1440, 2560); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  //size(768, 1366); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  //textFont(createFont("Arial", 30)); //set the font to arial 24
  textSize(30);
  noStroke(); //my code doesn't use any strokes.

  resetFill();
  
  for (int i = 0; i < 26; i++) {
    colors[i] = new Color(0, 0, 0);
  }
  
  colors[26] = new Color(255, 255, 255);
  colors[27] = new Color(255, 255, 255);
  
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
  resetFill();

 // image(watch,-200,200);
  fill(100);
  rect(keyBoardStartPoint, keyBoardStartPoint, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (finishTime!=0)
  {
    /*
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
    */
    
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

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
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
      colors[27] = new Color(255,99,71);
    }
    // if everything is correct
    else if (currentPhrase.length() == currentTyped.length()) {
      background(60,179,113);
      fill(0);
      colors[26] = new Color(255,255,255);
    }
    else {
      fill(128);
    }
    
    ////you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    //textAlign(LEFT); //align the text left
    //fill(128);
    //textFont(createFont("Arial", 24)); //set the font to arial 24
    //text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, keyBoardStartPoint, keyBoardStartPoint - 1440.0 * (150.0/768.0)); //draw the trial count
    //fill(255);
    //text("Target:   " + currentPhrase, keyBoardStartPoint, keyBoardStartPoint - 1440.0 * (100.0/768.0)); //draw the target string
    //text("Entered:  " + currentTyped, keyBoardStartPoint, keyBoardStartPoint - 1440.0 * (50.0/768.0)); //draw what the user has entered thus far 
    //fill(255, 0, 0);
    //rect(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea + 1440 * (25.0/768.0), 400, 400); //drag next button
    //fill(255);
    //text("NEXT > ", keyBoardStartPoint + sizeOfInputArea + 200, keyBoardStartPoint + sizeOfInputArea + 1440 * (25.0/768.0) + 200); //draw next label
    
    
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
    
    //my draw code
    /*
    textAlign(CENTER);
    text("" + currentLetter, 200+sizeOfInputArea/2, 200+sizeOfInputArea/3); //draw current letter
    fill(255, 0, 0);
    rect(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    fill(0, 255, 0);
    rect(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    */
    
    //Actual coords: rect(200 + 110, 200 + 165)
    
    if(! (selectedTopQuad || selectedRightQuad || selectedBottomQuad || selectedLeftQuad))
    {
      //Middle Button
      //Space and backspace
      if(selectedSpace == true)
      {
        //Space key
        fill(#add8e6);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, boxWidth, boxWidth, 3);
        //Backspace key
        fill(colors[27].red, colors[27].green, colors[27].blue);
        rect(keyBoardStartPoint + sizeOfInputArea/4 + boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, boxWidth, boxWidth, 3);
        if((mouseX < keyBoardStartPoint + sizeOfInputArea/4) || (mouseX > keyBoardStartPoint + sizeOfInputArea/2) || (mouseY < keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) || (mouseY > keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2))
        {
          selectedSpace = false;
        }
      }
      else if(selectedBackspace == true)
      {
        //Backspace key
        fill(#add8e6);
        rect(keyBoardStartPoint + sizeOfInputArea/4 + boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, boxWidth, boxWidth, 3);
        //Space key
        fill(colors[26].red, colors[26].green, colors[26].blue);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, boxWidth, boxWidth, 3);
        if((mouseX < keyBoardStartPoint + sizeOfInputArea/2) || (mouseX > keyBoardStartPoint + sizeOfInputArea * 3/4) || (mouseY < keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) || (mouseY > keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2))
        {
          selectedBackspace = false;
        }
      }
      else
      {
        fill(colors[26].red, colors[26].green, colors[26].blue);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, boxWidth, boxWidth, 3);
        fill(colors[27].red, colors[27].green, colors[27].blue);
        rect(keyBoardStartPoint + sizeOfInputArea/4 + boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, boxWidth, boxWidth, 3);
        fill(255);
      }
      stroke(0, 0, 0);
      //Top Quad
      quad(keyBoardStartPoint, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2);
      //Right Quad
      quad(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea - boxWidth, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2, keyBoardStartPoint + sizeOfInputArea - boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2);
      //Bottom Quad
      quad(keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea);
      //Left Quad
      quad(keyBoardStartPoint, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2+boxWidth/2, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea);
      
      fill(0, 0, 0);
      
      //Text: Space and Delete
      text("", keyBoardStartPoint + sizeOfInputArea/2 - sizeOfInputArea/6, keyBoardStartPoint + sizeOfInputArea/2 + sizeOfInputArea/24);
      textSize(30);
      text("Del", keyBoardStartPoint + (sizeOfInputArea * 3)/4 - sizeOfInputArea/5+10, keyBoardStartPoint + sizeOfInputArea/2 + sizeOfInputArea/24);
      
      //textSize(30);
      //Text: Top Quad
      fill(colors[0].red, colors[0].green, colors[0].blue);
      text("a", keyBoardStartPoint + horizontalMarginSide, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[1].red, colors[1].green, colors[1].blue);
      text("b", keyBoardStartPoint + horizontalMarginSide  + horizontalGap, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[2].red, colors[2].green, colors[2].blue);
      text("c", keyBoardStartPoint + horizontalMarginSide  + horizontalGap * 2, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[3].red, colors[3].green, colors[3].blue);
      text("d", keyBoardStartPoint + horizontalMarginSide  + horizontalGap * 3, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[4].red, colors[4].green, colors[4].blue);
      text("e", keyBoardStartPoint + horizontalMarginSide  + horizontalGap * 4, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[5].red, colors[5].green, colors[5].blue);
      text("f", keyBoardStartPoint + horizontalMarginSide  + horizontalGap * 5, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[6].red, colors[6].green, colors[6].blue);
      text("g", keyBoardStartPoint + horizontalMarginSide  + horizontalGap * 6, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      fill(colors[7].red, colors[7].green, colors[7].blue);
      text("h", keyBoardStartPoint + horizontalMarginSide  + horizontalGap * 7, keyBoardStartPoint + (sizeOfInputArea/2-boxWidth/2 )/2 - horizontalMarginTop);
      
      //Text: Right Quad
      fill(colors[8].red, colors[8].green, colors[8].blue);
      text("i", keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 + verticalMarginSide, keyBoardStartPoint + verticalMarginTop);
      fill(colors[9].red, colors[9].green, colors[9].blue);
      text("j", keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 + verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap);
      fill(colors[10].red, colors[10].green, colors[10].blue);
      text("k", keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 + verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 2);
      fill(colors[11].red, colors[11].green, colors[11].blue);
      text("l", keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 + verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 3);
      fill(colors[12].red, colors[12].green, colors[12].blue);
      text("m", keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 + verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 4);
      fill(colors[13].red, colors[13].green, colors[13].blue);
      text("n", keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 + verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 5);
      
      //Text: Left Quad
      /*
      text("s", keyBoardStartPoint + sizeOfInputArea/8 - 20, keyBoardStartPoint + 115);
      text("t", keyBoardStartPoint + sizeOfInputArea/8 - 20, keyBoardStartPoint + 115 + verticalGap);
      text("u", keyBoardStartPoint + sizeOfInputArea/8 - 20, keyBoardStartPoint + 115 + verticalGap * 2);
      text("v", keyBoardStartPoint + sizeOfInputArea/8 - 20, keyBoardStartPoint + 115 + verticalGap * 3);
      text("w", keyBoardStartPoint + sizeOfInputArea/8 - 20, keyBoardStartPoint + 115 + verticalGap * 4);
      textSize(24);
      text("xyz", keyBoardStartPoint + sizeOfInputArea/8 - 35, keyBoardStartPoint + 115 + verticalGap * 5);
      */
      
      fill(colors[20].red, colors[20].green, colors[20].blue);
      text("u", keyBoardStartPoint + sizeOfInputArea/8 - verticalMarginSide, keyBoardStartPoint + verticalMarginTop);
      fill(colors[21].red, colors[21].green, colors[21].blue);
      text("v", keyBoardStartPoint + sizeOfInputArea/8 - verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap);
      fill(colors[22].red, colors[22].green, colors[22].blue);
      text("w", keyBoardStartPoint + sizeOfInputArea/8 - verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 2);
      fill(colors[23].red, colors[23].green, colors[23].blue);
      text("x", keyBoardStartPoint + sizeOfInputArea/8 - verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 3);
      fill(colors[24].red, colors[24].green, colors[24].blue);
      text("y", keyBoardStartPoint + sizeOfInputArea/8 - verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 4);
      fill(colors[25].red, colors[25].green, colors[25].blue);
      text("z", keyBoardStartPoint + sizeOfInputArea/8 - verticalMarginSide, keyBoardStartPoint + verticalMarginTop + verticalGap * 5);
      
      //textSize(11);
      //Text: Bottom Quad
      fill(colors[12].red, colors[12].green, colors[12].blue);
      text("m", keyBoardStartPoint + horizontalMarginSide, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
      fill(colors[13].red, colors[13].green, colors[13].blue);
      text("n", keyBoardStartPoint + horizontalMarginSide + horizontalGap, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
      fill(colors[14].red, colors[14].green, colors[14].blue);
      text("o", keyBoardStartPoint + horizontalMarginSide + horizontalGap * 2, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
      fill(colors[15].red, colors[15].green, colors[15].blue);
      text("p", keyBoardStartPoint + horizontalMarginSide + horizontalGap * 3, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
      fill(colors[16].red, colors[16].green, colors[16].blue);
      text("q", keyBoardStartPoint + horizontalMarginSide + horizontalGap * 4, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
      fill(colors[17].red, colors[17].green, colors[17].blue);
      text("r", keyBoardStartPoint + horizontalMarginSide + horizontalGap * 5, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);     
      fill(colors[18].red, colors[18].green, colors[18].blue);
      text("s", keyBoardStartPoint + horizontalMarginSide + horizontalGap * 6, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
      fill(colors[19].red, colors[19].green, colors[19].blue);
      text("t", keyBoardStartPoint + horizontalMarginSide + horizontalGap * 7, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth + sizeOfInputArea/8 +  horizontalMarginTop);
    }
    else
    {
      if(selectedTopQuad == true)
      {
        stroke(0, 0, 0);
        line(keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2);
        
        if(mouseY > keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2 && mouseY < keyBoardStartPoint + sizeOfInputArea && mouseX < keyBoardStartPoint + (sizeOfInputArea/8) * 8)
          setFill(mouseX, keyBoardStartPoint, sizeOfInputArea/8, 7);
        
        if(mouseY > keyBoardStartPoint + sizeOfInputArea || mouseY < keyBoardStartPoint  || mouseX < keyBoardStartPoint || mouseX > keyBoardStartPoint + sizeOfInputArea)
          selectedTopQuad = false;
        
        fill(sectionFill[0]);
        rect(keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[1]);
        rect(keyBoardStartPoint + sizeOfInputArea/8, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[2]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 2, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[3]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 3, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[4]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 4, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[5]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 5, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[6]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 6, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[7]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 7, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        
        fill(0, 0, 0);
        textSize(30);
        //Text: Top Quad
        fill(colors[0].red, colors[0].green, colors[0].blue);
        text("a", keyBoardStartPoint + sizeOfInputArea/24, keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[1].red, colors[1].green, colors[1].blue);
        text("b", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8), keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[2].red, colors[2].green, colors[2].blue);
        text("c", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 2, keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[3].red, colors[3].green, colors[3].blue);
        text("d", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 3, keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[4].red, colors[4].green, colors[4].blue);
        text("e", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 4, keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[5].red, colors[5].green, colors[5].blue);
        text("f", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 5, keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[6].red, colors[6].green, colors[6].blue);
        text("g", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 6, keyBoardStartPoint + sizeOfInputArea *  0.80);
        fill(colors[7].red, colors[7].green, colors[7].blue);
        text("h", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 7, keyBoardStartPoint + sizeOfInputArea *  0.80);
      }
      
      if(selectedRightQuad == true)
      {
        stroke(0, 0, 0);
        line(keyBoardStartPoint + (3 * sizeOfInputArea)/4, keyBoardStartPoint, keyBoardStartPoint + (3 * sizeOfInputArea)/4, keyBoardStartPoint + sizeOfInputArea);
        
        if(mouseY < keyBoardStartPoint + sizeOfInputArea && mouseX > keyBoardStartPoint && mouseX < keyBoardStartPoint + sizeOfInputArea * 3/4)
          setFill(mouseY, keyBoardStartPoint, sizeOfInputArea/6, 5);
          
        if(mouseY > keyBoardStartPoint + sizeOfInputArea || mouseY < keyBoardStartPoint  || mouseX < keyBoardStartPoint || mouseX > keyBoardStartPoint + sizeOfInputArea)
          selectedRightQuad = false;
        
        fill(sectionFill[0]);
        rect(keyBoardStartPoint, keyBoardStartPoint, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[1]);
        rect(keyBoardStartPoint, keyBoardStartPoint + (sizeOfInputArea/6), sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[2]);
        rect(keyBoardStartPoint, keyBoardStartPoint + (sizeOfInputArea/6) * 2, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[3]);
        rect(keyBoardStartPoint, keyBoardStartPoint + (sizeOfInputArea/6) * 3, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[4]);
        rect(keyBoardStartPoint, keyBoardStartPoint + (sizeOfInputArea/6) * 4, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[5]);
        rect(keyBoardStartPoint, keyBoardStartPoint + (sizeOfInputArea/6) * 5, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        
        fill(0, 0, 0);
        textSize(30);
        //Text: Right Quad
        fill(colors[8].red, colors[8].green, colors[8].blue);
        text("i", keyBoardStartPoint + sizeOfInputArea * 0.2, keyBoardStartPoint + sizeOfInputArea/9);
        fill(colors[9].red, colors[9].green, colors[9].blue);
        text("j", keyBoardStartPoint + sizeOfInputArea * 0.2, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6));
        fill(colors[10].red, colors[10].green, colors[10].blue);
        text("k", keyBoardStartPoint + sizeOfInputArea * 0.2, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 2);
        fill(colors[11].red, colors[11].green, colors[11].blue);
        text("l", keyBoardStartPoint + sizeOfInputArea * 0.2, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 3);
        fill(colors[12].red, colors[12].green, colors[12].blue);
        text("m", keyBoardStartPoint + sizeOfInputArea * 0.2, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 4);
        fill(colors[13].red, colors[13].green, colors[13].blue);
        text("n", keyBoardStartPoint + sizeOfInputArea * 0.2, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 5);
        
      }
      
      if(selectedBottomQuad == true)
      {
        stroke(0, 0, 0);
        line(keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2);
        
        if(mouseY < keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2 && mouseX > keyBoardStartPoint && mouseX < keyBoardStartPoint + sizeOfInputArea)
          setFill(mouseX, keyBoardStartPoint, sizeOfInputArea/8, 7);
          
        if(mouseY > keyBoardStartPoint + sizeOfInputArea || mouseY < keyBoardStartPoint  || mouseX < keyBoardStartPoint || mouseX > keyBoardStartPoint + sizeOfInputArea)
          selectedBottomQuad = false;
        
        fill(sectionFill[0]);
        rect(keyBoardStartPoint, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[1]);
        rect(keyBoardStartPoint + sizeOfInputArea/8, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[2]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 2, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[3]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 3, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[4]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 4, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[5]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 5, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[6]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 6, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        fill(sectionFill[7]);
        rect(keyBoardStartPoint + (sizeOfInputArea/8) * 7, keyBoardStartPoint, sizeOfInputArea/8, sizeOfInputArea/2 + boxWidth/2);
        
        fill(0, 0, 0);
        textSize(30);
        //Text: Top Quad
        fill(colors[12].red, colors[12].green, colors[12].blue);
        text("m", keyBoardStartPoint + sizeOfInputArea/24, keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[13].red, colors[13].green, colors[13].blue);
        text("n", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8), keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[14].red, colors[14].green, colors[14].blue);
        text("o", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 2, keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[15].red, colors[15].green, colors[15].blue);
        text("p", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 3, keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[16].red, colors[16].green, colors[16].blue);
        text("q", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 4, keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[17].red, colors[17].green, colors[17].blue);
        text("r", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 5, keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[18].red, colors[18].green, colors[18].blue);
        text("s", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 6, keyBoardStartPoint + sizeOfInputArea *  0.20);
        fill(colors[19].red, colors[19].green, colors[19].blue);
        text("t", keyBoardStartPoint + sizeOfInputArea/24 + (sizeOfInputArea/8) * 7, keyBoardStartPoint + sizeOfInputArea *  0.20);
      }
      
      if(selectedLeftQuad == true)
      {
        stroke(0, 0, 0);
        line(keyBoardStartPoint + (sizeOfInputArea)/4, keyBoardStartPoint, keyBoardStartPoint + (sizeOfInputArea)/4, keyBoardStartPoint + sizeOfInputArea);
        
        if(mouseY < keyBoardStartPoint + sizeOfInputArea && mouseX > keyBoardStartPoint + sizeOfInputArea/4 && mouseX < keyBoardStartPoint + sizeOfInputArea)
          setFill(mouseY, keyBoardStartPoint, sizeOfInputArea/6, 5);
          
        if(mouseY > keyBoardStartPoint + sizeOfInputArea || mouseY < keyBoardStartPoint  || mouseX < keyBoardStartPoint || mouseX > keyBoardStartPoint + sizeOfInputArea)
          selectedLeftQuad = false;
        
        fill(sectionFill[0]);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[1]);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + (sizeOfInputArea/6), sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[2]);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + (sizeOfInputArea/6) * 2, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[3]);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + (sizeOfInputArea/6) * 3, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[4]);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + (sizeOfInputArea/6) * 4, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        fill(sectionFill[5]);
        rect(keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + (sizeOfInputArea/6) * 5, sizeOfInputArea * 3/4, sizeOfInputArea/6);
        
        fill(0, 0, 0);
        textSize(30);
        //Text: Right Quad
        fill(colors[20].red, colors[20].green, colors[20].blue);
        text("u", keyBoardStartPoint + sizeOfInputArea * 0.8, keyBoardStartPoint + sizeOfInputArea/9);
        fill(colors[21].red, colors[21].green, colors[21].blue);
        text("v", keyBoardStartPoint + sizeOfInputArea * 0.8, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6));
        fill(colors[22].red, colors[22].green, colors[22].blue);
        text("w", keyBoardStartPoint + sizeOfInputArea * 0.8, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 2);
        fill(colors[23].red, colors[23].green, colors[23].blue);
        text("x", keyBoardStartPoint + sizeOfInputArea * 0.8, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 3);
        fill(colors[24].red, colors[24].green, colors[24].blue);
        text("y", keyBoardStartPoint + sizeOfInputArea * 0.8, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 4);
        fill(colors[25].red, colors[25].green, colors[25].blue);
        text("z", keyBoardStartPoint + sizeOfInputArea * 0.8, keyBoardStartPoint + sizeOfInputArea/9 + (sizeOfInputArea/6) * 5);
        
      }
      
    }
  }
  
}

void setFill(float mousePos, float beginBoundary, float increment, int numIncrements)
{
  for(int i = numIncrements; i >= 0; i--)
  {
    if(mousePos > beginBoundary + (increment * i))
    {
      sectionFill[i] = 200;
      break;
    }
  }   
}

void resetFill()
{
  for(int i = 0; i < sectionFill.length; i++)
  {
    sectionFill[i] = 255;
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void mouseReleased()
{
  if(selectedTopQuad == true)
  {
    if(sectionFill[0] == 200) {
      currentTyped += "a";
      if (intelligentInput) {
        intelligentNext('a');
      }
    }
    else if(sectionFill[1] == 200) {
      currentTyped += "b";
      if (intelligentInput) {
        intelligentNext('b');
      }
    }
    else if(sectionFill[2] == 200) {
      currentTyped += "c";
      if (intelligentInput) {
        intelligentNext('c');
      }
    }
    else if(sectionFill[3] == 200) {
      currentTyped += "d";
      if (intelligentInput) {
        intelligentNext('d');
      }
    }
    else if(sectionFill[4] == 200) {
      currentTyped += "e";
      if (intelligentInput) {
        intelligentNext('e');
      }
    }
    else if(sectionFill[5] == 200) {
      currentTyped += "f";
      if (intelligentInput) {
        intelligentNext('f');
      }
    }
    else if(sectionFill[6] == 200) {
      currentTyped += "g";
      if (intelligentInput) {
        intelligentNext('g');
      }
    }
    else if(sectionFill[7] == 200) {
      currentTyped += "h";
      if (intelligentInput) {
        intelligentNext('h');
      }
    }
  }
  
  if(selectedRightQuad == true)
  {
    if(sectionFill[0] == 200) {
      currentTyped += "i";
      if (intelligentInput) {
        intelligentNext('i');
      }
    }
    else if(sectionFill[1] == 200) {
      currentTyped += "j";
      if (intelligentInput) {
        intelligentNext('j');
      }
    }
    else if(sectionFill[2] == 200) {
      currentTyped += "k";
      if (intelligentInput) {
        intelligentNext('k');
      }
    }
    else if(sectionFill[3] == 200) {
      currentTyped += "l";
      if (intelligentInput) {
        intelligentNext('l');
      }
    }
    else if(sectionFill[4] == 200) {
      currentTyped += "m";
      if (intelligentInput) {
        intelligentNext('m');
      }
    }
    else if(sectionFill[5] == 200) {
      currentTyped += "n";
      if (intelligentInput) {
        intelligentNext('n');
      }
    }
  }
  
  if(selectedBottomQuad == true)
  {
    if(sectionFill[0] == 200) {
      currentTyped += "m";
      if (intelligentInput) {
        intelligentNext('m');
      }
    }
    else if(sectionFill[1] == 200) {
      currentTyped += "n";
      if (intelligentInput) {
        intelligentNext('n');
      }
    }
    else if(sectionFill[2] == 200) {
      currentTyped += "o";
      if (intelligentInput) {
        intelligentNext('o');
      }
    }
    else if(sectionFill[3] == 200) {
      currentTyped += "p";
      if (intelligentInput) {
        intelligentNext('p');
      }
    }
    else if(sectionFill[4] == 200) {
      currentTyped += "q";
      if (intelligentInput) {
        intelligentNext('q');
      }
    }
    else if(sectionFill[5] == 200) {
      currentTyped += "r";
      if (intelligentInput) {
        intelligentNext('r');
      }
    }
    else if(sectionFill[6] == 200) {
      currentTyped += "s";
      if (intelligentInput) {
        intelligentNext('s');
      }
    }
    else if(sectionFill[7] == 200) {
      currentTyped += "t";
      if (intelligentInput) {
        intelligentNext('t');
      }
    }
  }
  
  if(selectedLeftQuad == true)
  {
    if(sectionFill[0] == 200) {
      currentTyped += "u";
      if (intelligentInput) {
        intelligentNext('u');
      }
    }
    else if(sectionFill[1] == 200) {
      currentTyped += "v";
      if (intelligentInput) {
        intelligentNext('v');
      }
    }
    else if(sectionFill[2] == 200) {
      currentTyped += "w";
      if (intelligentInput) {
        intelligentNext('w');
      }
    }
    else if(sectionFill[3] == 200) {
      currentTyped += "x";
      if (intelligentInput) {
        intelligentNext('x');
      }
    }
    else if(sectionFill[4] == 200) {
      currentTyped += "y";
      if (intelligentInput) {
        intelligentNext('y');
      }
    }
    else if(sectionFill[5] == 200) {
      currentTyped += "z";
      if (intelligentInput) {
        intelligentNext('z');
      }
    }
  }
  
  if(selectedSpace == true) {
    currentTyped +=  " ";
    if (intelligentInput) {
        intelligentNext(' ');
      }
      colors[26] = new Color(255, 255, 255);
    }
  
  if(selectedBackspace == true)
  {
    if (currentTyped.length() > 0) {
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    }
    if (intelligentInput) {
        intelligentNext('.');
    }
    colors[26] = new Color(255, 255, 255);
    colors[27] = new Color(255, 255, 255);
  }
  
  selectedTopQuad = false;
  selectedRightQuad = false;
  selectedLeftQuad = false;
  selectedBottomQuad = false;
  selectedSpace = false;
  selectedBackspace = false;
}

float checkClickSide(float x0, float y0, float x1, float y1)
{
  return (x1 - x0) * (mouseY - y0) - (mouseX - x0) * (y1 - y0);
}


void mousePressed()
{
  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea + 1440 * (25.0/768.0), 400, 400)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
  
  //You are allowed to have a next button outside the 2" area
  if (!didMouseClick(keyBoardStartPoint, keyBoardStartPoint, sizeOfInputArea, sizeOfInputArea))
  {
    return;
  }
  else if(started == false)
  {
    started = true;
    return;
  }
  
  //Top Quadrant check
  if((mouseY < keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) && (checkClickSide(keyBoardStartPoint, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) <= 0) && (checkClickSide(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2) >= 0))
  {
    //Enter mode 2 with choices at bottom
    selectedTopQuad = true;
    //System.out.println("selectedTopQuad: " + selectedTopQuad);
  }
  
  //Right Quadrant check
  //else if((mouseX > keyBoardStartPoint + (3 * sizeOfInputArea)/4) && (checkClickSide(keyBoardStartPoint + (3 * sizeOfInputArea)/4, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint) <= 0) && (checkClickSide(keyBoardStartPoint + (3 * sizeOfInputArea)/4, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea) <= 0))
  else if((mouseX > keyBoardStartPoint + sizeOfInputArea - boxWidth) && (checkClickSide(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea - boxWidth, keyBoardStartPoint + sizeOfInputArea/2-boxWidth/2) <= 0) && (checkClickSide(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea - boxWidth, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2) >= 0))
  {
    //Enter mode 2 with choices at bottom
    selectedRightQuad = true;
    //System.out.println("selectedRightQuad: " + selectedRightQuad);
  }
  
  //Bottom Quadrant check
  else if((mouseY > keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2) && (checkClickSide(keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2) >= 0) && (checkClickSide(keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea/4 + boxWidth + boxWidth, keyBoardStartPoint + sizeOfInputArea/2+boxWidth/2) <= 0))
  {
    //Enter mode 2 with choices at bottom
    selectedBottomQuad = true;
    //System.out.println("selectedBottomQuad: " + selectedBottomQuad);
  }
  
  //Left Quadrant check
  else if((mouseX < keyBoardStartPoint + sizeOfInputArea/4) && (checkClickSide(keyBoardStartPoint, keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) >= 0) && (checkClickSide(keyBoardStartPoint, keyBoardStartPoint + sizeOfInputArea, keyBoardStartPoint + sizeOfInputArea/4, keyBoardStartPoint + sizeOfInputArea/2+boxWidth/2) <= 0))
  {
    //Enter mode 2 with choices at bottom
    selectedLeftQuad = true;
    //System.out.println("selectedLeftQuad: " + selectedLeftQuad);
  }
  
  //Space check
  else if((mouseX >= keyBoardStartPoint + sizeOfInputArea/4) && (mouseX <= keyBoardStartPoint + sizeOfInputArea/2) && (mouseY > keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) && (mouseY < keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2))
    selectedSpace = true;
    
  //Backspace check
  else if((mouseX >= keyBoardStartPoint + sizeOfInputArea/2) && (mouseX <= keyBoardStartPoint + sizeOfInputArea * 3/4) && (mouseY > keyBoardStartPoint + sizeOfInputArea/2 - boxWidth/2) && (mouseY < keyBoardStartPoint + sizeOfInputArea/2 + boxWidth/2))
    selectedBackspace = true;
  
  /*
  if (didMouseClick(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  {
    currentLetter --;
    if (currentLetter<'_') //wrap around to z
      currentLetter = 'z';
  }

  if (didMouseClick(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  {
    currentLetter ++;
    if (currentLetter>'z') //wrap back to space (aka underscore)
      currentLetter = '_';
  }

  if (didMouseClick(200, 200, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
  {
    if (currentLetter=='_') //if underscore, consider that a space bar
      currentTyped+=" ";
    else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
      currentTyped+=currentLetter;
  }
  
  */
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
    colors[i] = new Color(0, 0, 0);
  }
}

// show the next possible letters
void show() {
  if (curr != root && curr != null) {
    TrieNode[] next = curr.next;
    for (int i = 0; i < 26; i++) {
      if (next[i] != null) {
        colors[i] = new Color(255,99,71);
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