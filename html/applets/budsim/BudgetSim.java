import java.awt.*;
import java.applet.*;
import java.util.*;


import java.awt.Event;
import edu.iastate.csl.util.PlayableApplet;
import edu.iastate.csl.util.AppletRecorder;
import edu.iastate.csl.util.GetDataFrame;
import edu.iastate.csl.util.Axis;
import edu.iastate.csl.util.Graph;


public class BudgetSim extends Applet implements PlayableApplet
    {
    public static BudgetSim me;
    double levelVal = 20.0;
    int yValue=20;
    static double fConstant=0.0, dConstant=1.0;
    Thread myThread;

    static int hour;
    static double faucetValue, drainValue;
    private ReadoutPanel water_level_recorder;
    private LevelGraph lgraph ;
    private RateGraph rgraph ;
    private double WaterLevel[], FlowRate[];
    private int time[];
 	private Frame f;
 	private Font x;
 	private String s;
 	private Label l;
    private Graphics g;
    private Axis scale ;
    private Image faucet1;
    private AudioClip Sfaucet;
    private AudioClip Sdrain;
    private boolean playA1 = false;
    private boolean playA2 = true;

    private boolean faucetChangeable = true;
    private boolean drainChangeable = false;

    // Delay
    private final int DELAY = 500;

    // Image file names
    private String LGRAPH_BACKGROUND = new String ("media/sky.jpg");
    private String RGRAPH_BACKGROUND = new String ("");
    private String APPLET_BACKGROUND = new String ("");
    private String PICTURE_BACKGROUND = new String ("");
    private String CONTAINER_IMAGE = new String ("media/tub.gif");
    private String DRAIN_AUDIO = new String ("media/streamb.au");
    private String FAUCET_AUDIO = new String ("media/wind.au");
    private String FAUCET_IMAGE = new String ("media/faucet3.gif");

    // Panels for GUI
    private Panel display_panel;
    private Panel left_panel, right_panel;
    private Panel picture_panel;
    private Panel lgraph_panel, rgraph_panel;
    private Panel lgraph_control_panel,rgraph_control_panel;
    private Panel control_panel;

    // Portrait
    private PicPortrait picture;

    // Background Image
    private Image background_image;
    // Choice Boxes
    private CheckboxGroup lgraph_choice;
    private Checkbox lgraph_line,lgraph_point;
    private CheckboxGroup rgraph_choice;
    private Checkbox rgraph_line, rgraph_point;

    private int MY_EVENT = -100;

    // For applet recording
    private AppletRecorder ar;
    private String filepath;
    private String mode;
    private Vector steps;


    
    private void addComponent (Panel p,Component c, GridBagLayout g,
                               GridBagConstraints gc, int row,
                               int column, int width, int height)
       {
       // Set gridx & gridy

       gc.gridx = column;
       gc.gridy = row;

       // Set the gridwidth & gridheight
       gc.gridwidth = width;
       gc.gridheight = height;

       g.setConstraints (c,gc);
       p.add (c);
       }

    private void auto_dripping ()
      {

      btnStart.disable ();
      btnContinue.disable ();

      if (playA2) Sdrain.loop();

      while ((hour >=0 && hour < 6) || (hour >= 18 && hour < 24))
        {

         lblTime.setText ("Time: " + (hour+1) + " hrs");
         if (hour == 23)
          lblDirections.setText("Directions : Click Start then wait for the next message");
         else
          if (hour == 5)
           lblDirections.setText ("Directions : Adjust Faucet.Then click on Continue");
          else
           lblDirections.setText("Directions : Wait for the next message");

         try
           {
           Thread.sleep(DELAY);
           }
         catch (InterruptedException e) {}

         setLevel1();

         time[hour]=hour;
         WaterLevel[hour]=levelVal;
         FlowRate [hour] =fConstant;

         picture.paint (picture.getGraphics());
         lgraph_plot();
         rgraph_plot();

         hour ++;
        }

      if (playA2) Sdrain.stop();

      btnStart.enable ();
      btnContinue.enable ();
      }

    public void flow() { if (playA1) Sfaucet.play(); }


    public Image getFaucetImage ()
       {
        return faucet1;
       }

    public Axis getScale ()
       {
        return scale;
       }

    public int getyValue()
       {
        return yValue;
       }

    private void getParameters()
    {
        String parm = getParameter("faucetChangeable");
        if (parm != null)
            faucetChangeable = parm.equalsIgnoreCase("true");
        parm = getParameter("drainChangeable");
        if (parm != null)
            drainChangeable = parm.equalsIgnoreCase("true");
            
	}

    public boolean handleEvent(Event event) {

        if ( event.target == btnContinue && event.id == Event.ACTION_EVENT) 
        {
            sendData();
            triggered_dripping ();
            return true;
        }

        if (event.target == faucet) 
        {
            if (faucetChangeable ) 
            {

                    if (hour <6 || hour >18)
                    {
                        faucetValue = fConstant;
                        faucet.setValue((int) fConstant);
                    }
                    else 
                    {
                        faucetValue = faucet.getValue();
                    }
                    faucet.setValue((int) faucetValue);
            }
            else 
            {
                faucetValue = fConstant;
                faucet.setValue((int) fConstant);
            }
            lblFaucet.setText("Faucet: " + faucet.getValue() + " liter/hr");
            return true;
        }
        if (event.target == drain) 
        {
            if (!drainChangeable) 
            {
                drain.setValue((int) dConstant);
                lblDrain.setText(drain.getValue() + " liter/hr");
            }
            else 
            {
                drainValue = drain.getValue();
                lblDrain.setText("Drain: " + drain.getValue() + " liter/hr");
            }
            
            return true;
        }


        if (event.target == btnStart && event.id == Event.ACTION_EVENT) 
        {
            sendDataStart();
            start_afresh ();
            auto_dripping ();
            return true;
        }

        if ( (event.target == lgraph_line || event.target == lgraph_point )
             && event.id == Event.ACTION_EVENT) 
        {
            lgraph_plot ();
            return true;
        }

        if ( (event.target == rgraph_line || event.target == rgraph_point )
             && event.id == Event.ACTION_EVENT) 
        {
            rgraph_plot ();
            return true;
        }
        
        return super.handleEvent(event);
    }


    public void init() 
    {
        Font f;

        f = new Font ("TimesRoman", Font.BOLD, 12);
        setFont (f);

        me = this;

        hour = 0;

        WaterLevel = new double[25];
        FlowRate = new double[25];
        time = new int[25];

        setBackground(Color.lightGray);
        getParameters();

        // Initialize the arrays
        init_plot_data ();

        // Draws a 3 D Border
        make_3D_border ();


        // Creates a portrait & draws the
        // picture inside it.
        make_picture_panel ();

        // Create the Control Panel
        make_control_panel ();

        // Create the Graph Panel
        make_graph_panel ();

        // Initialize Multi-Media Resources
        init_multi_media_resources();

        // Create the Left & Right Panels
        make_left_panel ();

        make_right_panel ();

        GridBagLayout gbLayout = new GridBagLayout ();
        GridBagConstraints gbConstraints = new GridBagConstraints ();

        Panel p = new Panel ();
        p.setLayout (gbLayout);

        gbConstraints.fill = GridBagConstraints.BOTH;

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        addComponent (p, left_panel,gbLayout,
                      gbConstraints, 0,0,1,1);

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        addComponent (p, right_panel,gbLayout,
                      gbConstraints, 0,1,1,1);


        // Put all of 'em together
        setLayout (new FlowLayout(FlowLayout.CENTER));
        add (p);

        btnContinue.disable ();

        ar = new AppletRecorder();
        filepath = getParameter("filepath");
        mode = getParameter("mode");
        if (mode == null) System.out.println("Applet Parameter mode is required");
        ar.open(filepath, mode, this);
        
        water_level_recorder.setValue(levelVal);
    }

    private void init_multi_media_resources()
       {
	    // The message box
	    s= "Adjust the faucet & drain values; then click Continue button.";
	    x= new Font("Courier", Font.BOLD, 14);

	    // Faucet Image
	    faucet1=getImage(getCodeBase(),FAUCET_IMAGE);
        waitForImage (this,faucet1);

        Sdrain = getAudioClip( getCodeBase(),DRAIN_AUDIO);
        Sfaucet = getAudioClip( getCodeBase(),FAUCET_AUDIO);

        // Background Image
        if (APPLET_BACKGROUND.equals (""))
          background_image = null;
        else
          {
          background_image = getImage (getCodeBase(), APPLET_BACKGROUND);
          waitForImage (this,background_image);
          }
       }

    private void init_plot_data ()
      {
        for (int i=0; i < 24; i++)
          {
            time[i] = -1;
            WaterLevel[i] = -1;
            FlowRate[i] = -1;
          }
      }

    public void leak() { if (playA2) Sdrain.play(); }

    private boolean lgraph_plot (int hour)
      {
        if (time [hour] == -1)
          return false;

        if (lgraph_choice.getCurrent().getLabel().equalsIgnoreCase ("Point"))
          lgraph.setPlotMode(Graph.POINT, Color.red);

        lgraph.plot(time[hour], WaterLevel[hour]);
        return true;
      }

    private void lgraph_plot ()
      {
        lgraph.clear();

        set_lgraph_mode ();

        for (int i=0; i < 24; i++)
          {
            if ( ! lgraph_plot(i) )
              {
              return;
              }
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
        g.drawLine(0,2,bnd.width-3, 2);
        // vertical black (Left side)
        g.drawLine(0,0,0,bnd.height-1);
        g.drawLine(1,0,1,bnd.height-2);
        g.drawLine(2,0,2,bnd.height-3);

        g.setColor(Color.white);
        // horizontal white (bottom)
        g.drawLine(1,bnd.height-1,bnd.width-1,bnd.height-1);
        g.drawLine(2,bnd.height-2,bnd.width-2,bnd.height-2);
        g.drawLine(3,bnd.height-3,bnd.width-3,bnd.height-3);
        //vertical white (right side)
        g.drawLine(bnd.width-1,0,bnd.width-1,bnd.height-1);
        g.drawLine(bnd.width-2,1,bnd.width-2,bnd.height-2);
        g.drawLine(bnd.width-3,2,bnd.width-3,bnd.height-3);

    }

    private void make_control_panel ()
       {
        Panel faucet_p,faucet_panel;
        Panel drain_p, drain_panel;
        Panel message_panel, message_box_panel;
        Panel dummy_control_panel;
        Panel p1,p2;
        GridBagLayout gbLayout;
        GridBagConstraints gbConstraints;

        // Faucet Scroll Bar Label
        lblFaucet=new Label("Faucet: 0 liter/hr");

        // Faucet Scroll Bar
        faucet= new SafeScrollbar(Scrollbar.HORIZONTAL, 0,1,0,3); //10);
        faucet.setBackground (Color.blue);

        // Panel for Faucet Scroll Bar Label
        faucet_p = new Panel ();
        faucet_p.setLayout (new FlowLayout (FlowLayout.CENTER));
        faucet_p.add (lblFaucet);


        gbLayout = new GridBagLayout ();
        gbConstraints = new GridBagConstraints ();

        // Panel for both the Scroll Bar & Label
        faucet_panel = new Panel ();
        faucet_panel.setLayout (gbLayout);
        gbConstraints.fill = GridBagConstraints.BOTH;
        gbConstraints.weightx = 4;
        gbConstraints.weighty = 1;
        addComponent (faucet_panel, faucet_p,gbLayout,
                      gbConstraints, 0,0,4,1);

        Panel faucet_temp_panel = new Panel ();
        faucet_temp_panel.setLayout (new BorderLayout());

        faucet_min_label = new Label (""+ faucet.getMinimum()+ "   ");
        faucet_temp_panel.add ("West", faucet_min_label);

        faucet_temp_panel.add ("Center", faucet);

        faucet_max_label = new Label ("  "+ (faucet.getMaximum()-faucet.getVisible()) );
        faucet.max=faucet.getMaximum() - faucet.getVisible();
        // to make max correct on mac:
        // faucet_max_label = new Label ("   "+ (faucet.getMaximum())); //-faucet.getVisible()) );
        faucet_temp_panel.add ("East", faucet_max_label);

        gbConstraints.weightx = 4;
        gbConstraints.weighty = 3;
        addComponent (faucet_panel, faucet_temp_panel, gbLayout,
                      gbConstraints, 1,0,4,3);


        lblDrain=new Label("Drain: 1 liter/hr");

        drain= new Scrollbar(Scrollbar.HORIZONTAL, 1,2,0,10);
        drain.setBackground (Color.red);


        // Panel for Drain Scroll Bar Label
        drain_p = new Panel ();
        drain_p.setLayout (new FlowLayout (FlowLayout.CENTER));
        drain_p.add (lblDrain);

        gbLayout = new GridBagLayout ();
        gbConstraints = new GridBagConstraints ();

        // Panel for both the Scroll Bar & Label
        drain_panel = new Panel ();
        drain_panel.setLayout (gbLayout);

        gbConstraints.fill = GridBagConstraints.BOTH;
        gbConstraints.weightx = 4;
        gbConstraints.weighty = 1;
        addComponent (drain_panel, drain_p,gbLayout,
                      gbConstraints, 0,0,4,1);

        gbConstraints.weightx = 4;
        gbConstraints.weighty = 3;
        addComponent (drain_panel, drain,gbLayout,
                      gbConstraints, 1,0,4,3);

        lblTime = new Label ("Time: 0 hrs ");

        // Make it long enough to fit other labels.
        lblDirections = new Label("Directions: Click Start to start the Simulation                     ");


        message_panel = new Panel ();

        gbLayout = new GridBagLayout ();
        gbConstraints = new GridBagConstraints ();
        gbConstraints.anchor = GridBagConstraints.WEST;
        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        gbConstraints.insets = new Insets(0,10,0,10);
        
        water_level_recorder = new ReadoutPanel ("Water-Level: ");
        
        message_panel.setLayout (gbLayout);
        addComponent(message_panel, lblTime, 
                        gbLayout, gbConstraints, 0,0,1,1);
        addComponent(message_panel, new Label ("Drain: 1 liter/hr"),
                        gbLayout, gbConstraints, 1,0,1,1);
        gbConstraints.anchor = GridBagConstraints.EAST;
        addComponent(message_panel, water_level_recorder,
                        gbLayout, gbConstraints, 0,1,1,1);

        btnStart= new Button("    Start    ");
        btnContinue= new Button("Continue");

        Panel btnStart_panel, btnContinue_panel;

        btnStart_panel = new Panel ();
        btnStart_panel.setLayout (new FlowLayout (FlowLayout.CENTER));
        btnStart_panel.add (btnStart);

        btnContinue_panel = new Panel ();
        btnContinue_panel.setLayout (new FlowLayout (FlowLayout.CENTER));
        btnContinue_panel.add (btnContinue);

        gbLayout = new GridBagLayout ();
        gbConstraints = new GridBagConstraints ();
        dummy_control_panel = new Panel();
        dummy_control_panel.setLayout (gbLayout);

        gbConstraints.fill = GridBagConstraints.BOTH;

        gbConstraints.weightx = 4;
        gbConstraints.weighty = 1;
        gbConstraints.insets = new Insets(5,0,5,0);
        addComponent (dummy_control_panel, lblDirections, gbLayout, gbConstraints, 0,0,4,1);

        gbConstraints.weightx = 4;
        gbConstraints.weighty = 2;
        gbConstraints.insets = new Insets(0,0,25,0);
        addComponent (dummy_control_panel, faucet_panel, gbLayout, gbConstraints, 1,0,4,2);

        gbConstraints.weightx = 4;
        gbConstraints.weighty = 2;
        gbConstraints.insets = new Insets(0,0,15,0);
        addComponent (dummy_control_panel, message_panel, gbLayout, gbConstraints,3,0,4,2);

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        addComponent (dummy_control_panel, btnStart_panel, gbLayout, gbConstraints, 5,1,1,1);
        addComponent (dummy_control_panel, btnContinue_panel, gbLayout, gbConstraints, 5,2,1,1);

        control_panel = new Panel ();
        control_panel.setLayout (new FlowLayout (FlowLayout.CENTER));
        control_panel.add ( dummy_control_panel);
       }

    private void make_graph_panel ()
       {
        Panel p;

        Image back ;

        if (LGRAPH_BACKGROUND.equals (""))
          back = null;
        else
          {
          back = getImage (getCodeBase(),LGRAPH_BACKGROUND);
          waitForImage (this,back);
          }

        Rectangle r = bounds();

        lgraph = new LevelGraph(r.width/2-30, r.height/2-75, getGraphics());


        if (back != null)
          {
          lgraph.setImage (back);
          }

        lgraph.setXBounds(0,24,4.0,0.0);
        lgraph.setYBounds(0,100,20.0,0.0);
        lgraph.setLabels("Time", "Level");

        if (RGRAPH_BACKGROUND.equals (""))
          back = null;
        else
          {
          back = getImage (getCodeBase(),RGRAPH_BACKGROUND);
          waitForImage (this,back);
          }


        rgraph = new RateGraph (r.width/2-30,r.height/2-75);


        if (back != null)
          {
          rgraph.setImage (back);
          }


        rgraph.setXBounds(0,24,4.0,0.0);
        rgraph.setYBounds(0, 10, 2.0, 0.0);
        rgraph.setLabels("Time", "Rate");

        lgraph_choice = new CheckboxGroup ();
        lgraph_line = new Checkbox ("Line", lgraph_choice,true);
        lgraph_point = new Checkbox ("Point", lgraph_choice,false);

        rgraph_choice = new CheckboxGroup ();
        rgraph_line = new Checkbox ("Line", rgraph_choice,true);
        rgraph_point = new Checkbox ("Point", rgraph_choice,false);


        p = new Panel ();
        p.setLayout (new FlowLayout (FlowLayout.CENTER));
        p.add (lgraph_line);
        p.add (lgraph_point);

        lgraph_control_panel = new Panel();

        GridBagLayout gbLayout = new GridBagLayout ();
        GridBagConstraints gbConstraints = new GridBagConstraints ();

        lgraph_control_panel.setLayout (gbLayout);

        gbConstraints.fill = GridBagConstraints.BOTH;
        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;

        addComponent(lgraph_control_panel,new Label("Top-Graph", Label.CENTER),
                        gbLayout, gbConstraints,0,0,1,1);
        addComponent(lgraph_control_panel,p,
                        gbLayout, gbConstraints,1,0,1,1);

        p = new Panel ();
        p.setLayout (new FlowLayout (FlowLayout.CENTER));
        p.add (rgraph_line);
        p.add (rgraph_point);

        rgraph_control_panel = new Panel();

        rgraph_control_panel.setLayout (gbLayout);
        addComponent(rgraph_control_panel,new Label("Bottom-Graph",Label.CENTER),
                        gbLayout, gbConstraints,0,0,1,1);
        addComponent(rgraph_control_panel,p,
                        gbLayout, gbConstraints,1,0,1,1);

       }

    private void make_left_panel ()
       {

        GridBagLayout gbLayout = new GridBagLayout ();
        GridBagConstraints gbConstraints = new GridBagConstraints ();

        left_panel = new Panel ();
        left_panel.setLayout (gbLayout);


        gbConstraints.fill = GridBagConstraints.BOTH;

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        addComponent ( left_panel,picture_panel,gbLayout,
                      gbConstraints, 0,0,1,1);

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        addComponent ( left_panel,control_panel,gbLayout,
                      gbConstraints, 1,0,1,1);
       }

    private void make_picture_panel ()
       {
        Image back, container;
        Rectangle r = bounds ();
        Graphics g = getGraphics ();

        if (PICTURE_BACKGROUND.equals (""))
          back = null;
        else
          {
          back = getImage (getCodeBase(), PICTURE_BACKGROUND);
          waitForImage (this,back);
          }

        if (CONTAINER_IMAGE.equals (""))
          container = null;
        else
          {
          container = getImage (getCodeBase(), CONTAINER_IMAGE);
          waitForImage(this,container);
          }

        picture = new PicPortrait (back,container,r.width/2 -50,r.height/2-50);

        picture_panel = new Panel ();
        picture_panel.setLayout (new FlowLayout (FlowLayout.CENTER));
        picture_panel.add (picture);
       }

    private void make_right_panel ()
       {
        Panel p2;

        p2 = new Panel ();
        p2.setLayout (new FlowLayout(FlowLayout.CENTER, 25, 0));
        p2.add (lgraph_control_panel);
        p2.add (rgraph_control_panel);

        GridBagLayout gbLayout = new GridBagLayout();
        GridBagConstraints gbConstraints = new GridBagConstraints();

        right_panel = new Panel ();
        right_panel.setLayout (gbLayout);


        gbConstraints.fill = GridBagConstraints.BOTH;

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 2;
        gbConstraints.insets = new Insets(5,5,5,5);
        addComponent (right_panel, lgraph,gbLayout,
                      gbConstraints, 0,0,1,2);
        addComponent (right_panel, rgraph,gbLayout,
                      gbConstraints, 2,0,1,2);

        gbConstraints.weightx = 1;
        gbConstraints.weighty = 1;
        addComponent (right_panel, p2 ,gbLayout,
                      gbConstraints, 4,0,1,2);
       }

    public void paint (Graphics g) {

       Rectangle bnd = bounds ();
       setBackground (Color.lightGray);

	   if (background_image != null)
	     {
	     g.drawImage (background_image,0,0,bnd.width-1,bnd.height-1,this);
         waitForImage (this,background_image);
	     }
       make_3D_border();
       picture.paint (picture.getGraphics());
    }

    public void playStart(Vector values)
    {
        // clear the screen
        reset();

        btnStart.disable ();
        btnContinue.disable ();

        //save values for later user
	    steps = values;
    }

    public void playStep(int stepIndex)
    {
	    // get the hashtable of values
        Hashtable ht = (Hashtable)steps.elementAt(stepIndex);

	    // convert the strings that are in the hashtable to the proper type
        int faucetVal = (Integer.valueOf((String)ht.get("faucet"))).intValue();
        int drainVal = (Integer.valueOf((String)ht.get("drain"))).intValue();
        int timeVal = (Integer.valueOf((String)ht.get("time"))).intValue();
        double waterVal = (Double.valueOf((String)ht.get("water"))).doubleValue();

        if ( faucetVal == -1)
        {   
            // Start was pressed
            start_afresh ();
            auto_dripping ();
        }
        else
        {
            faucet.setValue(faucetVal);
            drain.setValue(drainVal);
            hour = timeVal;
            levelVal = waterVal;

            triggered_dripping();
            // Set the Faucet & Drain Values
        }
    }

    public void playClose()
    {
        btnStart.enable ();
        btnContinue.enable ();
    }

    public void reset ()
      {
      // Reset the hour variable
      hour = 0;

      // Clear the graphs
      init_plot_data ();
      lgraph.clear ();
      rgraph.clear ();


      // Reset the Image
      levelVal = 21.0;
      setLevel1 ();

      water_level_recorder.setValue (levelVal);

      // Update the Picture
      picture.paint (picture.getGraphics());
      lgraph.paint (lgraph.getGraphics());
      rgraph.paint (rgraph.getGraphics());

      }

    private void rgraph_plot ()
      {
        rgraph.clear();
        set_rgraph_mode ();

        for (int i=0; i < 24; i++)
          {
            if ( ! rgraph_plot(i) )
              return;
          }
      }

    private boolean rgraph_plot (int hour)
      {
        if (time [hour] == -1)
          return false;

        if (rgraph_choice.getCurrent().getLabel().equalsIgnoreCase ("Point"))
          rgraph.setPlotMode(Graph.POINT, Color.black);

        rgraph.plot(time[hour], FlowRate[hour]);
        return true;
      }

    private void sendData ()
    {

       Hashtable ht = new Hashtable();

       ht.put("faucet", new Integer(faucet.getValue()));
       ht.put("drain", new Integer(drain.getValue()));
       ht.put("time", new Integer(hour));
       ht.put("water", new Double(levelVal));

       ar.putValues(ht);

    }

    private void sendDataStart()
    {

       Hashtable ht = new Hashtable();

       ht.put("faucet", new Integer(-1));
       ht.put("drain", new Integer(-1));
       ht.put("time", new Integer(-1));
       ht.put("water", new Integer(-1));

       ar.putValues(ht);

    }

    public void setLevel() {

        levelVal += (faucet.getValue()-drain.getValue())*1.0;
        if (levelVal > 100.0) levelVal = 100.0;
        if (levelVal < 0.0) levelVal = 0.0;
        float[] value=new float[3];

        value[0]=(float)0.0;
        value[1]=(float)((levelVal-100.0)/100.0);
        value[2]=(float)0.0;

        yValue = (int)(levelVal);
        lblFaucet.setText("Faucet: " + faucet.getValue() + " liter/hr");
        lblDrain.setText("Drain: " + drain.getValue() +" liter/hr");

        water_level_recorder.setValue ((double)yValue);

    }

    public void setLevel1() {


        levelVal += (fConstant-dConstant)*1.0;
        if (levelVal > 100.0) levelVal = 100.0;
        if (levelVal < 0.0) levelVal = 0.0;
        float[] value=new float[3];

        value[0]=(float) 0.0;
        value[1]=(float) ((levelVal-100.0)/100.0);
        value[2]=(float) 0.0;
        yValue = (int)(levelVal);
        lblFaucet.setText("Faucet: " + faucet.getValue() + " liter/hr");
        lblDrain.setText("Drain: " + drain.getValue() + " liter/hr");

        water_level_recorder.setValue ((double)yValue);
    }


    private void set_lgraph_mode ()
      {

        if (lgraph_choice.getCurrent().getLabel().equalsIgnoreCase ("Line"))
          lgraph.setPlotMode(Graph.LINE, Color.red);
        else
          lgraph.setPlotMode(Graph.POINT, Color.red);
      }

    private void set_rgraph_mode ()
      {

        if (rgraph_choice.getCurrent().getLabel().equalsIgnoreCase ("Line"))
          rgraph.setPlotMode(Graph.LINE, Color.black);
        else
          rgraph.setPlotMode(Graph.POINT, Color.black);
      }



    private void start_afresh ()
    {
        init_plot_data ();

        btnContinue.disable ();
        btnStart.setLabel("  New Trial  ");

        set_lgraph_mode ();
        set_rgraph_mode ();

        levelVal = 20.0;
        water_level_recorder.setValue (levelVal);

        faucet.setValues (0, faucet.getVisible(), 0, 2 + faucet.getVisible());
        faucet_min_label.setText ("0  ");
        faucet_max_label.setText("  " + (faucet.getMaximum() - faucet.getVisible()));
        faucet.max=faucet.getMaximum() - faucet.getVisible();
        // to make max label correct on mac:
        // faucet_max_label.setText ("  " + faucet.getMaximum());
        lblFaucet.setText("Faucet: " + faucet.getValue() + " liter/hr");

        hour = 0;
    
    }

    public void stop ()
      {
            ar.close();
      }

    private void triggered_dripping ()
      {
      if ( hour >= 24 )
        return ;

      lblTime.setText ("Time: " + (hour+1) + " hrs");
      lblDirections.setText ("Directions : Adjust Faucet. Then click on Continue");

      try
       {
        Thread.sleep(DELAY);
       }
      catch (InterruptedException e) {}

      setLevel();

      picture.my_paint (picture.getGraphics());

      leak();

      time[hour]=hour;
      WaterLevel[hour]=levelVal;
      FlowRate [hour]=faucet.getValue();

      lgraph_plot ();
      rgraph_plot ();
      hour ++;

      if (hour >= 18)
      {
        btnContinue.disable ();
        btnStart.disable ();
        faucet.setValues (0, faucet.getVisible(), 0, 2 + faucet.getVisible());

        faucet_min_label.setText ("0");
        faucet_max_label.setText ("  " + (faucet.getMaximum()-faucet.getVisible()));
        faucet.max=faucet.getMaximum() - faucet.getVisible();
        
        // to make max right on a mac:
        // faucet_max_label.setText ("  " + faucet.getMaximum());


        lblFaucet.setText("Faucet: " + faucet.getValue() + " liter/hr");
        auto_dripping ();
        btnContinue.disable ();
        btnStart.setLabel("    Start    ");
        return;
      }

      int max, min;
      if ( faucet.getValue()+2 > 10)
        max = 10 + faucet.getVisible ();
      else
        max = faucet.getValue() + 2 + faucet.getVisible();

      if ( faucet.getValue()-2 < 0)
         min = 0;
      else
         min = faucet.getValue()-2;

      faucet.setValues (faucet.getValue(), faucet.getVisible(), min, max);

      faucet_min_label.setText ("" + min );
      faucet_max_label.setText ("  " + (max - faucet.getVisible()));
      faucet.max=faucet.getMaximum() - faucet.getVisible();
      
      // to make the max label right on the mac:
      // faucet_max_label.setText("  " + (max));

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


    //{{DECLARE_CONTROLS
    Choice View;
    Label label1;
    SafeScrollbar faucet;
    Scrollbar drain;
    Label faucet_min_label;
    Label faucet_max_label;
    Label lblFaucet;
    Label lblDrain;
    Label lblTime;
    Label lblDirections;
    Button btnStart;
    Button btnContinue;
    boolean suspended = true;
}
