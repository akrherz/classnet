import java.applet.*;
import java.awt.*;
import java.util.*;
import edu.iastate.csl.util.AppletRecorder;
import edu.iastate.csl.util.PlayableApplet;
import edu.iastate.csl.util.GetDataFrame;

public class AdvectionSim extends Applet implements PlayableApplet
{
    /*  Applet tag parameters:
        <PARAM NAME="gradient" VALUE="medium">  makes the gradient constant (user cannot change it)
        <PARAM NAME="speed" VALUE="25">         makes the speed constant (user cannot change it)
        <PARAM NAME="time" VALUE="4">           makes the duration constant (user cannot change it)
        <PARAM NAME="direction" VALUE="N">      makes the direction constant (user cannot change it)
        
        <PARAM NAME-"mode" VALUE="demo">  demo mode lets the applet work without any communication
                                          with a server  ("play" and "record" modes will communicate
                                          with AppletRecorderServer to store and retreive session data)
        <PARAM NAME="guess" VALUE="on">   lets the user guess what the final temp will be
        <PARAM NAME="random" VALUE="on">  has the computer randomly select values for the
                                          settings that have not been specified as constant
                                          (see above)    
        <PARAM NAME="formula" VALUE="on"> the formula for calculating the advection is shown
                                          Note that the height of the applet must be increased
                                          by about 85 to see the formula.
        the "mode" parameter is the only required parameter!!!
    */
    
    Image usMap,buffer;
    int spacer;
    int y,         // how many pixels the bars have moved from original position
        sx,sy;     // pixel location of Ames    
    
    // An additional option for the contour spacing can be added by
    // adding an element to each of space[], spactext[], and startT[]
    // and modifying numGradients
    int numGradients = 4;        // the number of items in space[], spacetext[], and startT[]
    int space[] = {20,35,50,75}; // take 5 times these values to get an approximate mileage
                                 // width for each band on the map (1 pixel = 5 miles)
    String spacetext[] = {"narrow","small","medium","wide"};
    int startT[] = {0,6,2,9};    // which gradient color band will be at the top of the map
                                 // the starting Ames temperature is based on this

    int time = 2;
    int initialTemp = 0;
    Advector adthread;
    double factor[] = { 1.0,0.7,0.0,-0.7,-1.0,-0.7,0,.7};  // cosine of the angle
    Color colors[] = {  new Color(0,0,255),     // 35 degrees
                        new Color(0,128,255),   // 40
                        new Color(128,255,255), // 45
                        new Color(0,255,0),     // 50
                        new Color(255,255,0),   // 55
                        new Color(255,255,255), // 60
                        new Color(220,220,220), // 65
                        new Color(200,200,200), // 70
                        new Color(128,128,128), // 75
                        new Color(128,64,64),   // 80
                        new Color(255,128,64),  // 85
                        new Color(255,128,128), // 90
                        new Color(255,0,128),   // 95
                        new Color(255,0,0),     // 100
                        new Color(64,64,64)    // >100
               };

    // default values for parameters given in the applet tag
    private String parmVals[] = {"","","","","","",""};
    private boolean parmEnabled[] = {true,true,true,true,true,false,false,false};
    final private int gradientIND = 0;
    final private int speedIND = 1;
    final private int directionIND = 2;
    final private int durationIND = 3;
    final private int tempIND = 4;
    final private int guessIND = 5;
    final private int randomIND = 6;
    final private int formulaIND = 7;

    // for recording and playing of sessions
    private AppletRecorder ar;
    private String filepath;
    private String mode;
    private Vector steps;

    public void init() {

        spacer = 20;
        y = 0;

        MakeGUI();
        usMap = getImage(getCodeBase(),"usmap.gif");
        waitForImage(this,usMap);

        initialTemp = Integer.parseInt(getTemp());
        tempval.setText(getTemp()+" F");

        setParameters();        

        ar = new AppletRecorder();
        filepath = getParameter("filepath");
        mode = getParameter("mode");
        ar.open(filepath,mode,this);

    }

    public void MakeGUI() {

    setLayout(null);
    addNotify();
    
    // wasn't working on pc  (if change this then change resize in set parameters too.
    //resize(insets().left + insets().right + 588, insets().top + insets().bottom + 395);

    map=new Panel();
    map.setLayout(null);
    add(map);
    map.reshape(insets().left + 14,insets().top + 7,560,292);

    speed= new Scrollbar(Scrollbar.HORIZONTAL, 1,1,1,11);
    speed.setLineIncrement(1);
    speed.setPageIncrement(2);
    add(speed);
    speed.reshape(insets().left + 135,insets().top + 325,84,16);

    duration= new Scrollbar(Scrollbar.HORIZONTAL, 2,1,1,6);
    duration.setLineIncrement(1);
    duration.setPageIncrement(2);
    add(duration);
    duration.reshape(insets().left + 346,insets().top + 325,68,16);

    direction= new Choice();
    add(direction);
    direction.reshape(insets().left + 259,insets().top + 325,42,26);
    direction.addItem("N");
    direction.addItem("NE");
    direction.addItem("E");
    direction.addItem("SE");
    direction.addItem("S");
    direction.addItem("SW");
    direction.addItem("W");
    direction.addItem("NW");

    SpacingLab=new Label("Contour Spacing", Label.CENTER);
    add(SpacingLab);
    SpacingLab.reshape(insets().left + 18,insets().top + 306,94,13);

    SpeedLab=new Label("Wind Speed", Label.CENTER);
    add(SpeedLab);
    SpeedLab.reshape(insets().left + 142,insets().top + 306,70,13);

    DirLab=new Label("Wind Direction", Label.CENTER);
    add(DirLab);
    DirLab.reshape(insets().left + 238,insets().top + 306,91,13);

    runNew=new Button("Run");
    add(runNew);
    runNew.reshape(insets().left + 505,insets().top + 325,65,26);

    speedval=new Label("5 knots", Label.CENTER);
    add(speedval);
    speedval.reshape(insets().left + 142,insets().top + 345,77,13);

    tempLab=new Label("Initial Temp");
    add(tempLab);
    tempLab.reshape(insets().left + 432,insets().top + 306,65,13);

    tempval=new Label("65 F", Label.CENTER);
    add(tempval);
    tempval.reshape(insets().left + 432,insets().top + 325,65,13);

    gradient= new Choice();
    add(gradient);
    gradient.reshape(insets().left + 23,insets().top + 322,84,26);
    for (int i=0; i<numGradients ; i++)
    {
        gradient.addItem(spacetext[i]);
    }

    widthVal=new Label(String.valueOf(5*space[0]) + " miles", Label.CENTER);
    add(widthVal);
    widthVal.reshape(insets().left + 18,insets().top + 348,94,13);

    durationLab=new Label("Duration", Label.CENTER);
    add(durationLab);
    durationLab.reshape(insets().left + 350,insets().top + 306,60,13);

    durationval = new Label("2 hours", Label.CENTER);
    add(durationval);
    durationval.reshape(insets().left + 350,insets().top + 345,60,13);

    fTempGuessLab = new Label("Enter your guess of the final Ames temperature:");                           
    fTempGuess = new TextField(3);
    fTempGuess.setEditable(true);
    result = new Label();
    
    formulaLab = new Label("Advection Formula:");
    formula = new Label("final temp = initial temp +/- [ wind speed * cosine(direction) * duration * contour temp/spacing ]");
    formula2 = new Label("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM");
    formula3 = new Label("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM");
    formula4 = new Label("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM");
    
    SpeedLab.setBackground(Color.lightGray);
    SpacingLab.setBackground(Color.lightGray);
    widthVal.setBackground(Color.lightGray);
    DirLab.setBackground(Color.lightGray);
    speedval.setBackground(Color.lightGray);
    tempLab.setBackground(Color.lightGray);
    tempval.setBackground(Color.lightGray);
    map.setBackground(Color.white);
    durationLab.setBackground(Color.lightGray);
    durationval.setBackground(Color.lightGray);
    setBackground(Color.lightGray);

    sx = 310; sy = 105;

    }
    //{{DECLARE_CONTROLS
    Panel map;

    Label SpacingLab;
    Choice gradient;
    Label widthVal;

    Label SpeedLab;
    Scrollbar speed;
    Label speedval;

    Label DirLab;
    Choice direction;

    Label durationLab;
    Scrollbar duration;
    Label durationval;

    Label tempLab;
    Label tempval;

    Button runNew;
    
    Label fTempGuessLab;
    TextField fTempGuess;
    Label result;
    int streak=0;
    
    Label formulaLab;
    Label formula;
    Label formula2;
    Label formula3;
    Label formula4;

    public void advDone()
    {
        if (parmEnabled[guessIND])
        {
            if (fTempGuess.getText().equals(getTemp()))
            {
                streak++;
                result.setText("Correct!   Winning streak: " + streak + " in a row");
            }
            else
            {
                streak = 0;
                result.setText("The final temp was " + getTemp() + " F");
            }
       
        }
        
        if (parmEnabled[formulaIND])
        {
            showAnswer();
        }

    }
    
    private void hideAnswer()
    {
        formula3.setText(" ");
        formula4.setText(" ");        
    }

    public void clickedRun() 
    {        
        int d = direction.getSelectedIndex();
        int spd = 5 * speed.getValue(); //(double)5*(new Integer(speed.getValue())).intValue();
        double dir = factor[d];
        
        play(getCodeBase(),"wind.au");
        adthread = new Advector(this,dir,(int)spd, getFinalTemp());
        adthread.start();
        sendData();
    }

    public void clickedReset() {
        if (adthread != null)
            adthread.stop();
        adthread = null;
        reset();
    }

    public void drawSpeed(Graphics g,int spd,int ex,int ey,int fx,int fy,int dx, int dy) {
        g.drawLine(sx,sy,ex,ey);
        if (spd == 10) {
            int x[] = {ex,ex+2*(fx+dx),ex+4*dx,ex};
            int y[] = {ey,ey+2*(fy+dy),ey+4*dy,ey};
            g.fillPolygon(x,y,4);
        } else {
            int ix = ex; int iy = ey;
            for (int i = 0; i < spd/2; i++) {
                g.drawLine(ix,iy,ix+fx,iy+fy);
                ix += dx;
                iy += dy;
            }
            if ((spd % 2) > 0) {
                g.drawLine(ix,iy,ix+fx/2,iy+fy/2);
            }
        }
    }

    private void drawSymbol(Graphics g) {
        g.setColor(Color.black);
        g.fillArc(sx-3,sy-3,6,6,0,360);
        int d = direction.getSelectedIndex();
        int spd = speed.getValue();
        int len = 20;
        int len45 = 14;
        switch(d) {
            case 0:
                drawSpeed(g,spd,sx,sy-len,5,0,0,2);
                break;
            case 1:
                drawSpeed(g,spd,sx+len45,sy-len45,3,3,-2,2);
                break;
            case 2:
                drawSpeed(g,spd,sx+len,sy,0,5,-2,0);
                break;
            case 3:
                drawSpeed(g,spd,sx+len45,sy+len45,-3,3,-2,-2);
                break;
            case 4:
                drawSpeed(g,spd,sx,sy+len,-5,0,0,-2);
                break;
            case 5:
                drawSpeed(g,spd,sx-len45,sy+len45,-3,-3,2,-2);
                break;
            case 6:
                drawSpeed(g,spd,sx-len,sy,0,-5,2,0);
                break;
            case 7:
                drawSpeed(g,spd,sx-len45,sy-len45,3,-3,2,2);
                break;
        }

        FontMetrics fm = g.getFontMetrics();
        int height = fm.getHeight();
        int widLab = fm.stringWidth(" Ames Temp:  ");
        int widVal;
        String temp = getTemp() + " F ";

        widVal = fm.stringWidth(temp);

        // temp label and value
        g.clearRect(insets().left+400, insets().top+3, widLab+2, height+2);
        g.drawString(" Ames Temp:  ", insets().left+401, insets().top+height);
        g.clearRect(insets().left+402+widLab, insets().top+3, widVal+2, height+2);
        g.drawString(temp, insets().left+403+widLab, insets().top+height);

        // Draw a bounding rectangle    x,y,w,h,raised
        g.draw3DRect(insets().left+399, insets().top+2, widLab+widVal+4, height+4, true);
    }

    private void fillFormula()
    {
        if (factor[direction.getSelectedIndex()] > 0 )
            formula2.setText( "= " + 
                            tempval.getText() + " - [ " +
                            speed.getValue()*5 + " miles/hr * " +
                            (int)(factor[direction.getSelectedIndex()]*10)/10.0 + " * " + // casting was necessary to cast so that it wouldn't have 0.70000...0001 in NS 4.? on pc
                            time + " hours * " +
                            5 + " F / " +
                            5 * space[gradient.getSelectedIndex()] + " miles ]");
        else
            formula2.setText( "= " + 
                            tempval.getText() + " + [ " +
                            speed.getValue()*5 + " miles/hr * " +
                            (int)(factor[direction.getSelectedIndex()]*-10)/10.0 + " * " + // casting was necessary to cast so that it wouldn't have 0.70000...0001 in NS 4.? on pc
                            time + " hours * " +
                            5 + " F / " +
                            5 * space[gradient.getSelectedIndex()] + " miles ]");
        
    }

    private void showAnswer()
    {
        if (factor[direction.getSelectedIndex()] > 0 )
            formula3.setText( "= " + 
                            tempval.getText() + " - " +
                            Math.round((float)(speed.getValue()*5 * factor[direction.getSelectedIndex()] * time * 5 / (5 * space[gradient.getSelectedIndex()])*100))/100.0 + " F ");  // guarantee only 2 decimal places
        else
            formula3.setText( "= " + 
                            tempval.getText() + " + " +
                            Math.round((float)(speed.getValue()*5 * factor[direction.getSelectedIndex()] * time * 5 / (5 * space[gradient.getSelectedIndex()])*-100))/100.0 + " F ");  // guarantee only 2 decimal places

        formula4.setText( "= " + 
                            Math.round( initialTemp -
                                        Math.round((float)(speed.getValue()*5 * factor[direction.getSelectedIndex()] * time * 5 / (5 * space[gradient.getSelectedIndex()])*100))/100.0)
                          + " F        (round up for .5 and higher, round down for less than .5)");

    }
    
    public int getFinalTemp()
    {
        // assumes simulation has not yet started!!!
        
        return( Math.round((float)
                (   Integer.parseInt(getTemp())
                    - ( speed.getValue()*5 
                        * factor[direction.getSelectedIndex()] 
                        * time  
                        * 5 / (5 * space[gradient.getSelectedIndex()])))));
        
    }
        
    public String getTemp() 
    {
        int temp = (int)(5.0*(double)(sy-y+spacer*startT[gradient.getSelectedIndex()])/spacer);
        return String.valueOf(temp);
    }

    public boolean handleEvent(Event event) {
        if (event.id == Event.ACTION_EVENT && event.target == direction) {
                selectedDirection();
                return true;
        }
        else
        if (event.id == Event.ACTION_EVENT && event.target == gradient) {
                selectedGradient();
                return true;
        }
        else
        if (event.id == Event.SCROLL_PAGE_UP && event.target == speed) {
                scrollPageUpSpeed();
                return true;
        }
        else
        if (event.id == Event.SCROLL_PAGE_DOWN && event.target == speed) {
                scrollPageDownSpeed();
                return true;
        }
        else
        if (event.id == Event.SCROLL_LINE_UP && event.target == speed) {
                scrollLineUpSpeed();
                return true;
        }
        else
        if (event.id == Event.SCROLL_LINE_DOWN && event.target == speed) {
                scrollLineDownSpeed();
                return true;
        }
        else
        if (event.id == Event.SCROLL_ABSOLUTE && event.target == speed) {
                scrollAbsoluteSpeed();
                return true;
        }
        else
        if ((event.target == duration) &&
            ((event.id == Event.SCROLL_PAGE_UP) || (event.id == Event.SCROLL_PAGE_DOWN) ||
             (event.id == Event.SCROLL_LINE_UP) || (event.id == Event.SCROLL_LINE_DOWN) ||
             (event.id == Event.SCROLL_ABSOLUTE))) {
                scrolledDuration();
                return true;
        }

        else
        if (event.id == Event.ACTION_EVENT && event.target == runNew) {
                if ((runNew.getLabel()).equalsIgnoreCase("Run"))
                {
                    clickedRun();
                    disableInput();
                    runNew.setLabel("New Trial");
                }
                else
                {
                    clickedReset();
                    enableInput();
                    runNew.setLabel("Run");
                }
                return true;
        }
        else

        return super.handleEvent(event);
    }

    public void paint(Graphics g) 
    {
        updatePanel();
        if (parmEnabled[guessIND])
            g.drawLine(0, insets().top + 363, bounds().width, insets().top + 363); 
        if (parmEnabled[formulaIND])
            g.drawLine(0, insets().top + 400, bounds().width, insets().top + 400);
            
        make_3D_border();
    }

    public void playStart(Vector values)
    {
        clickedReset();
        enableInput();
        runNew.setLabel("Run");
        steps = values;
    }

    public void playStep(int stepIndex)
    {
        if (adthread != null)
            adthread.stop();
        adthread = null;
        
	    // get the hashtable of values
        Hashtable ht = (Hashtable)steps.elementAt(stepIndex);

	    // convert the strings that are in the hashtable to the proper type
        String htgradient = (String)ht.get("gradient");
        int htspeed = (Integer.valueOf((String)ht.get("speed"))).intValue();
        int htduration = (Integer.valueOf((String)ht.get("duration"))).intValue();
        String htdirection = (String)ht.get("direction");
        String htguess;
        fTempGuess.setText("");
        if (parmEnabled[guessIND])
        {
            htguess = (String)ht.get("guess");
            fTempGuess.setText(htguess);
        }
        
        // run the simulation for the values
        gradient.select(htgradient);
        selectedGradient();

        speed.setValue(htspeed);
        scrollAbsoluteSpeed();

        duration.setValue(htduration);
        scrolledDuration();

        direction.select(htdirection);
        selectedDirection();

        clickedRun();
        runNew.setLabel("New Trial");
        disableInput();
        // eventually temp will be settable but right now there is nothing to do
    }

    public void playClose()
    {
	    // may do nothing
    	// do any cleanup that you want to do for when the window closes
    }

    private void reset() {
        y = 0;
        updatePanel();
        initialTemp = Integer.parseInt(getTemp());
        tempval.setText(getTemp()+" F");
        if (parmEnabled[guessIND])
        {
            result.setText("                                         ");
        }
        if (parmEnabled[formulaIND])
        {
            fillFormula();
            hideAnswer();
        }

    }

    public void scrollAbsoluteSpeed() {

        if (speed.getValue()>10) {speed.setValue(10);} // this is because the mac is allowing the speed to go one step higher

        int i = 5*speed.getValue();
        speedval.setText(String.valueOf(i)+" knots");
        updatePanel();
        if (parmEnabled[formulaIND])
        {
            fillFormula();
        }
    }

    public void scrollLineDownSpeed() {
        scrollAbsoluteSpeed();
    }

    public void scrollLineUpSpeed() {
        scrollAbsoluteSpeed();
    }

    public void scrollPageDownSpeed() {
        scrollAbsoluteSpeed();
    }

    public void scrollPageUpSpeed() {
        scrollAbsoluteSpeed();
    }

    private void scrolledDuration() {
        time = duration.getValue();
        durationval.setText(String.valueOf(time) +" hours");
        updatePanel();
        if (parmEnabled[formulaIND])
        {
            fillFormula();
        }
    }

    public void selectedDirection() {
        updatePanel();
        if (parmEnabled[formulaIND])
        {
            fillFormula();
        }
    }

    public void selectedGradient() {
        int i = gradient.getSelectedIndex();
        spacer = space[i];
        widthVal.setText(String.valueOf(5*spacer) + " miles");
        reset();  // will call fillFormula()
    }

    private void sendData ()
    {

       Hashtable ht = new Hashtable();

       ht.put("gradient", gradient.getSelectedItem());
       ht.put("speed", new Integer(speed.getValue()));
       ht.put("duration", new Integer(duration.getValue()));
       ht.put("direction", direction.getSelectedItem());
       if (!fTempGuess.getText().equals(""))       
            ht.put("guess", fTempGuess.getText());
       else
            ht.put("guess", "none");
       
       ar.putValues(ht);

    }

    private void setParameters() 
    {
    // makeGUI must be executed before this method so that gui components are initialized
    
        String p = getParameter("gradient");
        if (p != null) 
        {
            parmEnabled[gradientIND] = false;
            parmVals[gradientIND] = p;
            gradient.select(parmVals[gradientIND]);
            spacer = space[gradient.getSelectedIndex()];
            widthVal.setText(String.valueOf(5*spacer)+" miles");
        }

        p = getParameter("speed");
        if (p != null) 
        {
            try 
            {
                parmEnabled[speedIND] = false;
                parmVals[speedIND] = p;
                int i = 5*((new Integer(parmVals[speedIND])).intValue()/5);
                speed.setValue(i/5);
                speedval.setText(String.valueOf(i)+" knots");
                //updatePanel();
            }
            catch (NumberFormatException exc) { }
        }

        p = getParameter("dir");
        if (p != null) 
        {
            parmEnabled[directionIND] = false;
            parmVals[directionIND] = p;
            direction.select(parmVals[directionIND]);
        }

        p = getParameter("temp");
        if (p != null) 
        {
            parmEnabled[tempIND] = false;
            parmVals[tempIND] = p;
            initialTemp = (new Integer(parmVals[tempIND])).intValue();
        }

        p = getParameter("time");
        if (p != null) 
        {
            parmEnabled[durationIND] = false;
            parmVals[durationIND] = p;
            time = (new Integer(parmVals[durationIND])).intValue();
            duration.setValue(time);
            durationval.setText(String.valueOf(time)+" hours");
        }

        p = getParameter("guess");
        if (p != null) 
        {
            if (p.equalsIgnoreCase("on"))
            {
                parmEnabled[guessIND] = true;
                parmVals[guessIND] = "on";
                add(fTempGuessLab);
                fTempGuessLab.reshape(insets().left + 23, 
                            insets().top + 368,
                            fTempGuessLab.preferredSize().width, 
                            fTempGuessLab.preferredSize().height);
                            
                add(fTempGuess);
                fTempGuess.reshape(insets().left + 23 + fTempGuessLab.preferredSize().width, 
                        insets().top + 368, 
                        fTempGuess.preferredSize().width,
                        fTempGuess.preferredSize().height);

                add(result);
                result.reshape(insets().left + 23 + fTempGuessLab.preferredSize().width + fTempGuess.preferredSize().width, 
                    insets().top + 368, 
                    result.getFontMetrics(result.getFont()).stringWidth("Correct!   Winning Streak: 000 in a row"),
                    result.preferredSize().height);                                    
            }
            // else leave as default off
        }
        
        p = getParameter("random");         // this will randomly make selections for items
                                            // that were not given values in the applet tag
        if (p != null) 
        {
            if (p.equalsIgnoreCase("on"))
            {
                parmEnabled[randomIND] = true;
            }
            // else leave as default off
        }

        p = getParameter("formula");         // this controls whether the formula is shown
        if (p != null) 
        {
            if (p.equalsIgnoreCase("on"))
            {
                parmEnabled[formulaIND] = true;
                // draw line at bottom of screen
                
                // add 100 pixels to height
                // commented out cuz didn't work on pc
                // resize(size().width, size().height + 100);
                // add formula lines
                add(formulaLab);
                formulaLab.reshape(insets().left + 23, 
                            insets().top + 405,
                            formulaLab.preferredSize().width, 
                            formulaLab.preferredSize().height);
                            
                add(formula);
                formula.reshape(insets().left + 23, 
                        insets().top + 405 + formulaLab.preferredSize().height, 
                        formula.preferredSize().width,
                        formula.preferredSize().height);
                add(formula2);
                formula2.reshape(insets().left + 23 + 60, 
                    insets().top + 405 + formulaLab.preferredSize().height + formula.preferredSize().height, 
                    formula2.preferredSize().width,
                    formula2.preferredSize().height);
                formula2.setText(" ");
                add(formula3);
                formula3.reshape(insets().left + 23 + 60, 
                    insets().top + 405 + formula2.preferredSize().height + formulaLab.preferredSize().height + formula.preferredSize().height, 
                    formula3.preferredSize().width,
                    formula3.preferredSize().height);
                formula3.setText(" ");
                add(formula4);
                formula4.reshape(insets().left + 23 + 60, 
                    insets().top + 405 + formula3.preferredSize().height + formula2.preferredSize().height + formulaLab.preferredSize().height + formula.preferredSize().height, 
                    formula4.preferredSize().width,
                    formula4.preferredSize().height);
                formula4.setText(" ");
                fillFormula();
            }
            // else leave as default off
        }

        enableInput();

    }
        
    private void disableInput()
    {
        speed.disable();
        gradient.disable();
        direction.disable();
        duration.disable();        
    }

    private void enableInput()
    {
        if (!parmEnabled[gradientIND])
        {
            gradient.disable(); 
        }
        else 
        {
            if (parmEnabled[randomIND])     // when random is on then make a random selection
            {                               // and disable the parameter
                gradient.disable();
                int temp = (int) (Math.random() * gradient.countItems());
                gradient.select(temp);
                selectedGradient();
            }
            else gradient.enable();         // enable the parameter
        }

        
        if (!parmEnabled[speedIND])
        {
            speed.disable(); 
        }
        else 
        {
            if (parmEnabled[randomIND])     // when random is on then make a random selection
            {                               // and disable the parameter
                int temp = speed.getMinimum() + (int) ( Math.random() * (speed.getMaximum()-speed.getMinimum()+1) );
                speed.enable();
                speed.setValue(temp);
                scrollAbsoluteSpeed();
                speed.disable();
            }
            else speed.enable();         // enable the parameter
        }
        
        
        if (!parmEnabled[directionIND])
        {
            direction.disable(); 
            
        }
        else 
        {
            if (parmEnabled[randomIND])     // when random is on then make a random selection
            {                               // and disable the parameter
                direction.disable();
                int temp = (int) (Math.random() * direction.countItems() );
                direction.select(temp);
                selectedDirection();
            }
            else direction.enable();         // enable the parameter
        }
        
        
        if (!parmEnabled[durationIND])
        {
            duration.disable();
        }
        else
        {
            if (parmEnabled[randomIND])     // when random is on then make a random selection
            {                               // and disable the parameter
                int temp = duration.getMinimum() + (int) ( Math.random() * (duration.getMaximum()-duration.getMinimum()+1) );
                duration.enable();
                duration.setValue(temp);
                scrolledDuration();
                duration.disable();
            }
            else duration.enable();         // enable the parameter
        }

    }

    private void make_3D_border ()
       {
        // *****  Makes a border of width 3 ******** //
        Graphics g = getGraphics();
        Rectangle bnd = bounds();

        g.setColor(Color.black);
        // horizontal black (top)
        g.drawLine(0,0,bnd.width-1, 0);
        g.drawLine(0,1,bnd.width-2, 1);
        // vertical black (Left side)
        g.drawLine(0,0,0,bnd.height-1);
        g.drawLine(1,0,1,bnd.height-2);

        g.setColor(Color.white);
        // horizontal white (bottom)
        g.drawLine(1,bnd.height-1,bnd.width-1,bnd.height-1);
        g.drawLine(2,bnd.height-2,bnd.width-2,bnd.height-2);
        //vertical white (right side)
        g.drawLine(bnd.width-1,0,bnd.width-1,bnd.height-1);
        g.drawLine(bnd.width-2,1,bnd.width-2,bnd.height-2);

    }

    public void stop ()
    {
        ar.close();
    }

    public void updatePanel() {
        Dimension sz = map.size(); 
        if (buffer == null)
            buffer = map.createImage(sz.width,sz.height);
        Graphics g = buffer.getGraphics();
        g.clearRect(0,0,sz.width,sz.height);

        int gr = gradient.getSelectedIndex();
        int c = startT[gr];

        for (int r=0; r < sz.height; r+=spacer) {
            int h = r + y;
            g.setColor(colors[c]);
            g.fillRect(0,h,sz.width,spacer);
            g.setColor(Color.black);
            g.drawRect(0,h,sz.width,spacer);
            c++;
        }

        FontMetrics fm = g.getFontMetrics();
        int height = fm.getAscent()+1;
        int width = fm.stringWidth("000");
        c = startT[gr];
        for (int r=0; r < sz.height; r+=spacer) {
            int h = r + y;
            g.clearRect(3, h - height/2, fm.stringWidth(String.valueOf(5*c))+1, height+1);
            g.setColor(Color.black);
            g.drawString(String.valueOf(5*c), 3, h + height/2);
            c++;
        }

        drawSymbol(g);
        g.drawImage(usMap,0,0,sz.width,sz.height,this);
        map.getGraphics().drawImage(buffer,0,0,this);
    }

    public static void waitForImage(Component component,
                                    Image image) {
        MediaTracker tracker = new MediaTracker(component);
        try {
            tracker.addImage(image, 0);
            tracker.waitForID(0);
        }
        catch(InterruptedException e) {}
    }

}

class Advector extends Thread {
    AdvectionSim sim;
    double dir;
    int speed;
    int finalTemp;

    public Advector(AdvectionSim aSim, double aDir,int spd, int aFinalTemp) {
        sim = aSim;
        dir = aDir;
        speed = spd;
        finalTemp = aFinalTemp;
    }

    public void run() {
        if (dir > 0) {
            for (sim.y = 0; finalTemp <= Integer.parseInt(sim.getTemp()); sim.y++) {
                sim.updatePanel();
                try {
                    sleep(520-(int)speed*10);
                } catch (InterruptedException e) {}
            }
            sim.y--;
            
        } else if (dir < 0){
            for (sim.y = 0; finalTemp >= Integer.parseInt(sim.getTemp()) ; sim.y--) {
                sim.updatePanel();
                try {
                    sleep(520-(int)speed*10);
                } catch (InterruptedException e) {}
            }
            sim.y++;
        }
        sim.advDone();
    }
}