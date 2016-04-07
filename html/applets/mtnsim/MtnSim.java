import java.awt.*;
// awt.event needs to imported for 1.1 style events
//import java.awt.event.*;
import java.net.*;
import java.util.*;
import java.applet.*;
import edu.iastate.csl.util.AppletRecorder;
import edu.iastate.csl.util.PlayableApplet;
import edu.iastate.csl.util.GetDataFrame;
import edu.iastate.csl.util.Portrait;
import edu.iastate.csl.util.Graph;

public class MtnSim extends Applet implements PlayableApplet
/* must implement these for 1.1 style events
        implements ActionListener, AdjustmentListener
*/

{
    public static Applet me;
    public static ThreadGroup myGroup;
    private Airflow model;
    private int mtnwidth = 240;
    private int mtnheight = 150;
    private Portrait mtn = new Portrait(mtnwidth,mtnheight);
    private ReadoutPanel readout;
    private Controls cntrl;
    // Graphs
    private ETGraph etgraph; // = new ETGraph(160,150);
    private ATGraph atgraph; // = new ATGraph(160,150);
    public static int tempMax = 30;
    public static int tempMin = -20;
    public static int vaporMax = 50;
    public static int vaporMin = 0;
    public static int altMax = 5;
    public static int altMin = 0;
    // images and icons
    private Image marker;
    private Image leaf;
    private Image clouds[];
    // path of air parcel
    private Vector path;
    // Components to handle log information
    private Frame logFrame;
    private TextArea logText;
    private Vector history = new Vector(20);
    // Store feedback for components
    private Hashtable feedback = new Hashtable(20);
    private int tryidx = 0;
    private Color trycolors[] = {Color.blue,Color.green,Color.red};
    // possible parameters
    private double maxAltitude = 4.0; // km
    private double startPressure = 1000.0; // mb
    private double startAltitude = 0; // km
    private boolean showLog = true;
    private AudioClip thunder;
    private AudioClip wind;
    private boolean playAudio = false;

    // Storing and Retrieving Data to and from the server
    public static String filePath = "";
    public static String mode = "";
    private AppletRecorder ar;

    // for play mode
    private Vector steps;

    // GUI Components
    private Button logButton;
    private Button clearButton;

    public void init()
    {
        me = this;
        myGroup = Thread.currentThread().getThreadGroup();

        getParameters();
        makeGUI();

        if (playAudio) {
            thunder = getAudioClip( getCodeBase(),"media/thunder.au");
            wind = getAudioClip( getCodeBase(),"media/wind.au");
        }

        // initialize the socket for recording and playing
        ar = new AppletRecorder();
        ar.open(filePath, mode, this);

    }

    public boolean action(Event e, Object o)
    {
        if (e.target instanceof Button)
            return (processButtonClick(e.target));
        else return false;
    }

    private void addComponent(Component c,GridBagLayout gbl,int gw)
    {
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.gridwidth = gw;
        gbc.weightx = 0;
        gbc.weighty = 0;
        gbc.fill = GridBagConstraints.NONE;
	    gbc.insets = new Insets(3,3,3,3);
        gbl.setConstraints(c,gbc);
        add(c);
    }

	public void adjustSpeed()
	{   // maxSpeed - currentSpeed so that left of scrollbar is
        // slow and right of scrollbar is faster
	    if (model != null)
	    {
	        // if model has been started
            model.setDelay(cntrl.getMaxSpeed() - cntrl.getSpeed());
        }
    }

    private void clearScreen()
    {
        tryidx = 0;
		mtn.repaint();
		etgraph.clear();
		atgraph.clear();
		readout.setTemp(etgraph.getTemp());
		readout.tempsb.setValue((int)((etgraph.getTemp()+ReadoutPanel.tempOffset)*ReadoutPanel.Md+0.5));
		readout.setHumidity(etgraph.getHumidity());
		readout.humidsb.setValue((int)(etgraph.getHumidity() * ReadoutPanel.Md +0.5));
		readout.setTd(etgraph.getDewPoint());
		readout.setAltitude(startAltitude);
		readout.setCba(0);
		readout.setSlope(0);

		sendData(true);
    }

    public void destroy()
    {
    }

    private String formatLog(FontMetrics fm)
    {
        StringBuffer sbuf = new StringBuffer(100);
        sbuf.append(AirflowRec.heading(fm));
        Enumeration e = history.elements();

        while (e.hasMoreElements())
        {
            AirflowRec afc = (AirflowRec)e.nextElement();
            sbuf.append(afc.format(fm));
        }

        return sbuf.toString();
    }

    private void getParameters()
    {
        String parm = getParameter("maxAltitude");
        if (parm != null)
            maxAltitude = Integer.parseInt(parm);
        parm = getParameter("startPressure");
        if (parm != null)
            startPressure = Integer.parseInt(parm);
        parm = getParameter("startAltitude");
        if (parm != null)
            startAltitude = Integer.parseInt(parm);
        parm = getParameter("showLog");
        if (parm != null)
            showLog = parm.equalsIgnoreCase("true");
        parm = getParameter("playAudio");
        if (parm != null)
            playAudio = parm.equalsIgnoreCase("true");

        // Get ClassNet info
        mode = getParameter("mode");
        filePath = getParameter("filepath");

    }

    public boolean handleEvent(Event e)
    {
        if (e.target instanceof Airflow && e.id == Airflow.STOP)
        {
		    stopModel();
		    history.addElement(e.arg);
		    return true;
        }

		else if ((e.target instanceof Scrollbar) &&
		         (cntrl.isControlItem(Controls.SPEEDBAR, e.target)))
		{
		    adjustSpeed();
		    return true;
	    }

	    else if (e.id == Event.MOUSE_MOVE)
	    {
            try {
                showStatus((String)feedback.get(e.target));
            } catch (NullPointerException exp) {};
	    }

		return super.handleEvent(e);
    }

    private void makeGUI()
    {
        setBackground(Color.lightGray);

        GridBagLayout gbl = new GridBagLayout();
        setLayout(gbl);

        // mountain panel
        mtn.setBackground(Color.black);
        Image back =  getImage(getCodeBase(),"media/mtn.gif");
        waitForImage(this, back);
        mtn.setImage(back);

        Panel mtnp = new Panel();
        mtnp.add(mtn);
        // buttons panel
        Panel buttonsPanel = new Panel();

        Panel cntrl_panel = null;
        cntrl = new Controls();
        cntrl_panel = cntrl;

        buttonsPanel.setBackground (Color.lightGray);

        BorderLayout bl = new BorderLayout(5,15);
        buttonsPanel.setLayout(bl);

        buttonsPanel.add("North", cntrl_panel);

        logButton = new Button("View Log");
        clearButton = new Button("Clear Graphs");
        clearButton.disable();

        Panel buttons = new Panel();
        buttons.add(logButton);
        buttons.add(clearButton);

        buttonsPanel.add("South",buttons);

        if (!showLog) logButton.hide();

        // graphs
        readout = new ReadoutPanel();

        etgraph = new ETGraph(160,150,"00",getGraphics());
        etgraph.setReadout(readout);
        readout.setETGraph(etgraph);

        etgraph.setBackground(Color.white);
        etgraph.setXBounds(tempMin,tempMax,10,5.0);
        etgraph.setYBounds(vaporMin,vaporMax,10,5.0);
        etgraph.setLabels("Temperature (C)","Vapor Pressure (mb)");
        etgraph.setLabelColors(Color.blue, Color.blue);

        atgraph = new ATGraph(160,150,"0",getGraphics());
        atgraph.setBackground(Color.white);
        atgraph.setXBounds(tempMin,tempMax,10,5.0);
        atgraph.setYBounds(altMin,altMax,1,0.2);
        atgraph.setLabels("Temperature (C)","Altitude (km)");
        atgraph.setLabelColors(Color.blue, Color.blue);

        // Now add the components to the display
        addComponent(mtnp,gbl,1);
        addComponent(etgraph,gbl,GridBagConstraints.RELATIVE);
        addComponent(atgraph,gbl,GridBagConstraints.REMAINDER);
        addComponent(buttonsPanel,gbl,1);
        addComponent(readout,gbl,GridBagConstraints.REMAINDER);

            feedback.put(etgraph,"Plot of vapor pressure(mb) vs. temperature(C)");
            feedback.put(atgraph,"Plot of altitude(km) vs. temperature(C)");
            feedback.put(mtn,"Measure the weather on the mountain!");
            feedback.put(Controls.runButton,"Start the wind blowing.");
            feedback.put(logButton,"Display log of experimental results.");
            feedback.put(clearButton, "Clear the graphs");

        // get icons
        leaf = getImage(getCodeBase(),"media/leaf.gif");
        waitForImage(this,leaf);

        clouds = new Image[9];

        for (int i=0;i < 9; i++)
        {
            clouds[i] = getImage(getCodeBase(),"media/cloud"+(i+1)+"n.gif");
            waitForImage(this,clouds[i]);
        }

        marker = getImage(getCodeBase(),"media/leaf.gif");
        waitForImage(this,marker);
        etgraph.setIcon(marker);

        path = new Vector(4);
        path.addElement(new Point(10,135));
        path.addElement(new Point(110,45));
        path.addElement(new Point(125,45));
        //path.addElement(new Point(165,70));
        path.addElement(new Point(230,140));

    }

	public void paint(Graphics g)
	{
	    Rectangle bnd = bounds();
	    //g.draw3DRect(0,0,bnd.width-1, bnd.height-1, true);

        g.setColor(Color.black);
        // horizontal black (top)
        g.drawLine(0,0,bnd.width-1, 0);
        g.drawLine(0,1,bnd.width-2, 1);
        g.drawLine(0,2,bnd.width-3, 2);
        //vertical black (Left side)
        g.drawLine(0,0,0,bnd.height-1);
        g.drawLine(1,0,1,bnd.height-2);
        g.drawLine(2,0,2,bnd.height-3);

        g.setColor(Color.white);
        //horizontal white (bottom)
        g.drawLine(1,bnd.height-1,bnd.width-1,bnd.height-1);
        g.drawLine(2,bnd.height-2,bnd.width-2,bnd.height-2);
        g.drawLine(3,bnd.height-3,bnd.width-3,bnd.height-3);
        //vertical white (right side)
        g.drawLine(bnd.width-1,0,bnd.width-1,bnd.height-1);
        g.drawLine(bnd.width-2,1,bnd.width-2,bnd.height-2);
        g.drawLine(bnd.width-3,2,bnd.width-3,bnd.height-3);


	}

    public void playStart(Vector thesteps)
    {
        steps = thesteps;
        reset();
    }

    public void playStep(int stepIndex)
    {

        Hashtable ht = (Hashtable)steps.elementAt(stepIndex);

        double temp = (Double.valueOf((String)ht.get("temperature"))).doubleValue();
        double pressure = (Double.valueOf((String)ht.get("pressure"))).doubleValue();
        boolean clear = (Boolean.valueOf((String)ht.get("clear"))).booleanValue();

        if (clear)
        {
            // clear the screen
            clearScreen ();
        }
        else
        {
            // run the simulation for values temp and pressure
            etgraph.setTempHumid(temp,pressure);
            startModel();
        }

    }

    public void playClose()
    {
        reset();
    }

    private boolean processButtonClick(Object source)
    {
        if (source == logButton)
        {
            //showLogFrame();
		    showLogHTML();
		    return true;
		}

        else if (source == clearButton)
        {
            clearScreen(); // clearScreen will call sendData(true)
            return true;
        }

        else if (cntrl.isControlItem(Controls.RUN,source))
        {
            clearButton.disable();
            logButton.disable();
            cntrl.disableControlItem(Controls.RUN);

            startModel();  // startModel() will call sendData()
            return true;
        }

        else if (cntrl.isControlItem(Controls.RESETSIM,source))
        {
            clearButton.enable();
            logButton.enable();
            cntrl.enableControlItem(Controls.RUN);
            cntrl.enableControlItem(Controls.SPEEDBAR);
            cntrl.disableControlItem(Controls.RESETSIM);

            resetSim();
            return true;
        }

        return true;
    }

    public void reset ()
      {
      clearScreen ();
      history.removeAllElements();
      }

    public void resetSim()
    {
        mtn.repaint();
		readout.setTemp(etgraph.getTemp());
		readout.tempsb.setValue((int)((etgraph.getTemp()+ReadoutPanel.tempOffset)*ReadoutPanel.Md+0.5));
		readout.setHumidity(etgraph.getHumidity());
		readout.humidsb.setValue((int)(etgraph.getHumidity() * ReadoutPanel.Md +0.5));
		readout.setTd(etgraph.getDewPoint());
		readout.setAltitude(startAltitude);
		readout.setCba(0);
		readout.setSlope(0);
		etgraph.drawIcon();
		    etgraph.setAcceptInput (true);
		    readout.setAcceptInput(true);
	}

    private void sendData ()
    {
        sendData(false);
    }

    private void sendData(boolean clearPressed)
    {
        Hashtable ht = new Hashtable();

        ht.put("temperature", new Double(etgraph.getTemp()));
        ht.put("pressure", new Double(etgraph.getHumidity()));
        ht.put("clear", new Boolean(clearPressed));

        ar.putValues(ht);
    }

    private void showLogHTML()
    {
        HTMLDoc doc = new HTMLDoc(this,"Results","Experimental Results","BGCOLOR=#F0F0F0");
        doc.center(true);
        String headings[] = AirflowRec.heading();
        String values[] = new String[headings.length*history.size()];
        Enumeration e = history.elements();
        int i = 0;
        while (e.hasMoreElements()) {
            AirflowRec afr = (AirflowRec)e.nextElement();
            String v[] = afr.format();
            for (int j = 0; j < v.length; j++)
                values[i++] = v[j];
        }
        doc.table("Experimental Results",headings,values,true);
        doc.hr();
        doc.url("Return to Simulation","javascript:self.close()");
        doc.center(false);
        doc.close();
    }

    private void startModel()
    {
	    model = new Airflow(mtn);
	    model.setIcon(leaf,clouds);
        model.setStartConditions(maxAltitude,etgraph.getTemp(),etgraph.getHumidity(),startPressure,startAltitude,etgraph.getDewPoint());
        etgraph.setPlotMode(Graph.POINT,trycolors[tryidx]);
        
        etgraph.setAcceptInput (false);
        readout.setAcceptInput (false);
        
        atgraph.setPlotMode(Graph.POINT,trycolors[tryidx]);
        tryidx = ++tryidx % trycolors.length;
        model.setPath(path);
        // maxSpeed - currentSpeed so that left of scrollbar is
        // slow and right of scrollbar is faster
        model.setDelay(cntrl.getMaxSpeed() - cntrl.getSpeed());
        model.addObserver(etgraph);
        model.addObserver(atgraph);
        model.addObserver(readout);
        model.start();
        if (playAudio) { wind.play(); }

        sendData();
    }

    public void stop()
    {
        ar.close();
    }

    private void stopModel()
    {
        cntrl.enableControlItem(Controls.RESETSIM);
        cntrl.disableControlItem(Controls.SPEEDBAR);

    }

    public void thunder() 
    { 
        if (playAudio) thunder.play(); 
    }

    /*
    * Wait for the image to load for component
    * @param component The component to load the image into
    * @param image The image to load
    */
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
