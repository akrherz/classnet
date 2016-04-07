/*
$Header: /Lessons/RadSim/RadiationSim.java 24    3/09/99 7:47p Lisa $
*/
        /**************************************************************
        *    Copyright (c) 1998 by Pete Boysen                        *
        *             Iowa State University, Ames, IA                 *
        *                                                             *
        * E-Mail: pboysen@iastate.edu                                 *
        * Phone : (515)294-6663                                       *
        *                                                             *
        * Permission to use, copy, and distribute for non-commercial  *
        * purposes, is hereby granted without fee, providing the      *
        * above copyright notice appears in all copies and that both  *
        * the copyright notice and this permission notice appear in   *
        * supporting documentation.                                   *
        *                                                             *
        * THIS PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY    *
        * KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT       *
        * LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND    *
        * FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE *
        * QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.         *
        *                                                             *
        * IN NO EVENT SHALL IOWA STATE UNIVERSITY OR IOWA STATE       *
        * UNIVERSITY RESEARCH FOUNDATION, INC. BE LIABLE TO YOU FOR   *
        * ANY DAMAGES, INCLUDING ANY LOST PROFITS, LOST SAVINGS OR    *
        * OTHER INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING *
        * OUT OF THE USE OR INABILITY TO USE SUCH PROGRAM.            *
        *                                                             *
        **************************************************************/

import java.awt.image.*;
import java.awt.*;
import java.util.*;
import java.io.*;
import java.net.URL;

import edu.iastate.csl.util.Graph;
import edu.iastate.csl.util.AppletRecorder;
import edu.iastate.csl.util.PlayableApplet;
import edu.iastate.csl.util.GetDataFrame;

public class RadiationSim extends java.applet.Applet implements PlayableApplet
  {
    public static RadiationSim me;

    // GUI elements
    public MultiPortrait land_scape ;
    public Graph atgraph;
    private Panel pic_panel, graph_panel;
    private Panel control_panel;
    private Panel graph_control_panel;
    //private Button plotAllButton;
    private ControlItems cntrl;
    private GraphControlItems graph_cntrl;
    private Image icon;
    
    
    final int MAX_ALBEDOS = 4;                // maximum number of surface types
    final int MAX_NUM_ALTITUDES = 20;         // max number of altitudes the ballon can be at

    // Data for plotting
    private String plot_data_file = new String ("media/rs1.txt");
    private Vector pressure;
    private Vector altitude;    
    // Dimension1: Day/Nite   Dimension2: Albedo   Dimension3: Altitude Index
    // The array contains the value of the actual temperature in Kelvin
    private float temperature[][][];
    // Contains Points Plotted
    private boolean plotted[][][];

    // Color Controls & Images
    private static Color colors[][][];
    private Image images[][];

    // Image File Names
    private String PLOUGHED_FIELD_DAY = new String ("media/plowed.gif");
    private String GRASS_DAY = new String ("media/grass3.gif");
    private String SAND_DAY = new String ("media/land10.gif");
    private String FRESH_SNOW_DAY = new String ("media/snow.gif");

    private String ATGRAPH_BACKGROUND = new String ("");

    private String BALLOON = new String ("media/balloon.gif");

    // Current Image which is shown in the multiportrait
    private Image current_image ;

    // Command Line options
    private Image background_image;

    // Applet Height & Width
    private int WIDTH, HEIGHT;

    // Storing Data on server
    private String destination = "";
    private String mode = ""; // play for viewing what a student has done
                              // record for saving what a student is doing
                              // demo for no viewing or saving of sessions    
    private AppletRecorder ar;
    private Vector steps;

    public void init ()
      {
        setBackground (Color.lightGray);
        me = this;

        getParameters();

        init_colors ();
        init_images ();
        init_plotted_points ();

        makeGUI();
        load_plotting_data ();

        // Intialize Graph Parameters
        float min = (float)Math.floor ((double)this.toFarenheit (getMinTemperature ()) );
        float max = (float)Math.ceil ((double)this.toFarenheit (getMaxTemperature ()) );

        // initialize the graph
        atgraph.setLabels ("Temperature (F)"," Altitude (m)");
        atgraph.setXBounds ((int)min,(int)max,(int)(max-min)/8.0,2.0);
        atgraph.setYBounds (0,getMaxAltitude(),(int)getMaxAltitude()/7.0,0.5);

        // set up for applet recording and playing
        ar = new AppletRecorder();
        destination = getParameter("filepath");
        mode = getParameter("mode");
        ar.open(destination,mode,this);

      }

    public boolean action (Event e, Object o)
      {
        if ( e.target == graph_cntrl.getPlotButton() )
          {
            plot (land_scape.getAltitudeIndex());
            return true;
          }

        //if ( e.target == plotAllButton)
        //  {
        //    plotAll();
        //  }

        if ( e.target == graph_cntrl.getClearButton ())
          {
            init_plotted_points ();
            replot_all_points ();
            sendData(true);
            return true;
          }
        return true;
      }

    private void add(Component c,GridBagLayout gbl,int gw, int a)
      {
        GridBagConstraints gbc = new GridBagConstraints();

        gbc.gridwidth = gw;
        gbc.anchor = a;
        gbc.insets = new Insets(0,0,3,0);
        gbl.setConstraints(c,gbc);
        add(c);
      }


    public float getAltitude (int index)
    {
        // get the altitude given the index into the altitude array
      return ((Float)(altitude.elementAt(index))).floatValue();
    }

    public int getNumAltitudes ()
    {
        // return total number of altitudes supported
      return altitude.size();
    }

    public Color getColor (int col_index)
    {
        // returns the color to plot in for the current day/night and surface selections
      int albedo_index = cntrl.getSelectedSurfaceIndex();
      int day_nite_index = (cntrl.IsDay())?0:1;

      return colors[albedo_index][day_nite_index][col_index];
    }

    private Image get_dark_image (Image orig)
      {
        // returns a "blackened" version of the orig parameter
      Image darkImage;


      RGBImageFilter filter = new DarkFilter();
      FilteredImageSource source = new FilteredImageSource(orig.getSource(),filter);
      darkImage = createImage(source);

      return darkImage;
      }

    public static Color getPlotColor (int albedo_index, int day_nite_index)
    {
        // returns the color to plot in for the specified day/night and specified surface
        // parameters are indexes into colors array so use the constants for these indexes
      // 0 = day, 1 = night
      int col_index = 1;
      return colors[albedo_index][day_nite_index][col_index];
    }

    private float getMaxAltitude ()
    {
      float max = -1;
      
      for (int i=0; i < altitude.size(); i++)
        {
        float temp = ((Float)(altitude.elementAt(i))).floatValue();
        
        if ( temp > max )
          max = temp;
        }
      
      return max;
    }

    private float getMaxTemperature ()
    {
      float max = -1000;
      int i,j,k;

       for (i=0; i < 2; i++)
        for (j=0; j < MAX_ALBEDOS; j++)
          for (k=0; k < getNumAltitudes(); k++)
             if (max < temperature[i][j][k])
               max = temperature[i][j][k];

      return max;
    }

    private float getMinTemperature ()
    {
      float min = 1000;
      int i,j,k;

      for (i=0; i < 2; i++)
        for (j=0; j < MAX_ALBEDOS; j++)
          for (k=0; k < getNumAltitudes(); k++)
             if (min > temperature[i][j][k])
               min = temperature[i][j][k];

      return min;
    }

    private void getParameters()
      {
       this.background_image = getImage (getCodeBase(),getParameter ("BACKGROUND"));

       Rectangle bnd = bounds ();
       this.WIDTH = bnd.width -1;
       this.HEIGHT = bnd.height-1;

      }

    public boolean handleEvent(Event e)
    {
        // this is called every time a selection is made in the control panel
        if (( e.target == cntrl) && (e.id == ControlItems.COLORCHANGED))
        {
            int selected_surface_index = cntrl.getSelectedSurfaceIndex();
            int day_nite_index = (cntrl.IsDay())? 0 : 1;

            current_image = images [selected_surface_index][day_nite_index];
            land_scape.setImage (current_image);
            waitForImage (this,current_image);

            return true;
        }

        return super.handleEvent(e);
    }

    private void init_colors ()
    {
        colors = new Color [MAX_ALBEDOS][2][2];

        // Albedo 0 - Day (Sand, Day)
        colors[0][0][0] = Color.yellow;      // Text Color for printing
                                             // altitude above balloon
        colors[0][0][1] = Color.magenta;     // For plotting graph

        // Albedo 0 - Nite (Sand, Nite)
        colors[0][1][0] = Color.yellow;     // For printing altitude
        colors[0][1][1] = Color.red;        // For plotting graph

        // Albedo 1 - Day (Plowed Field, Day)
        colors[1][0][0] = Color.yellow;
        colors[1][0][1] = new Color(255,190,130);

        // Albedo 1 - Nite (Plowed Field, Nite)
        colors[1][1][0] = Color.yellow;
        colors[1][1][1] = new Color (160,80,0);

        // Albedo 2 - Day (Grass,Day)
        colors[2][0][0] = Color.blue;
        colors[2][0][1] = Color.green;
        // Albedo 2 - Nite (Grass, Nite)
        colors[2][1][0] = Color.yellow;
        colors[2][1][1] = new Color(1,150,70);

        // Albedo 3 - Day (Fresh Snow, Day)
        colors[3][0][0] = Color.black;
        colors[3][0][1] = Color.cyan;
        // Albedo 3 - Nite (Fresh Snow, Nite)
        colors[3][1][0] = Color.yellow;
        colors[3][1][1] = Color.blue;

    }

    private void init_images ()
      {
        images = new Image [MAX_ALBEDOS][2];

        // Albedo Sand
        images [0][0] = getImage (getCodeBase(),SAND_DAY);
        images [0][1] = get_dark_image (images[0][0]);

        // Albedo Plowed Field
        images [1][0] = getImage (getCodeBase(),PLOUGHED_FIELD_DAY);
        images [1][1] = get_dark_image (images[1][0]);


        // Albedo Grass
        images [2][0] = getImage (getCodeBase(),GRASS_DAY);
        images [2][1] = get_dark_image (images[2][0]);

        // Albedo Snow
        images [3][0] = getImage (getCodeBase(),FRESH_SNOW_DAY);
        images [3][1] = get_dark_image (images[3][0]);

        current_image = images[0][0];  // Start with Sand_Day
      }

    private void init_plotted_points ()
      {
        // set all points to not plotted
        
        int i,j,k;

        plotted = new boolean [2][MAX_ALBEDOS][MAX_NUM_ALTITUDES];

        for (i=0; i < 2; i++)
          for (j=0; j < MAX_ALBEDOS; j++)
             for (k=0; k < MAX_NUM_ALTITUDES; k++)
                plotted[i][j][k] = false;

      }

    private void load_plotting_data ()
    {
        // get the temperatures for each height for each surface
        // from the plot_data_file
       
       String s;
       int line_count = 0;

       pressure = new Vector();
       altitude = new Vector();
       temperature = new float[2][MAX_ALBEDOS][MAX_NUM_ALTITUDES];

       try
         {
         URL fileURL = new URL (getCodeBase() + plot_data_file);
         InputStream input = fileURL.openStream();
         DataInputStream in = new DataInputStream(input);

         while (true)
         {
            int n1,i,altitude_count;
            Float n2;
            StringTokenizer tok;

            s = in.readLine ();

            line_count ++;

            // Skip the 1st two lines
            if (line_count > 2)
            {
                if ( s == null)
                break;

                // Tokenize the string
                tok = new StringTokenizer (s);

                // Pressure
                n1= Integer.parseInt (tok.nextToken());
                pressure.addElement (new Integer (n1));

                // Altitude
                altitude.addElement (new Float(tok.nextToken()));
                altitude_count = altitude.size()-1;

                int n = cntrl.NUM_SURFACES;

                // Day data
                for (i=0; i < n; i++)
                {
                    // Read values for each albedo
                    n2 = new Float (tok.nextToken());
                    temperature[0][i][altitude_count] = n2.floatValue();
                }

                // Night Data
                for (i=0; i < n; i++ )
                {
                    n2 = new Float (tok.nextToken());
                    temperature[1][i][altitude_count] = n2.floatValue();
                }
            
            } // end if line_count > 2
         } // end while(true)

         in.close ();
       }
       
       catch (java.net.MalformedURLException e)
         {
         System.out.println ("MalFormed URL: " + getCodeBase() + plot_data_file);
         e.printStackTrace();
         return;
         }
       catch (IOException e)
         {
         System.out.println ("IO Error in Line #: " + line_count);
         e.printStackTrace();
         return;
         }
       catch (NumberFormatException e)
         {
         System.out.println ("Invalid Number in Line #: " + line_count);
         e.printStackTrace();
         return;
         }
       catch (NoSuchElementException e)
         {
         System.out.println ("UnExpected in Line #: " + line_count);
         e.printStackTrace();
         return;
         }
       catch (NullPointerException e)
         {
         System.out.println ("Line #" + line_count );
         e.printStackTrace();
         }

       //print_loaded_values ();
      }

    private void makeGUI ()
      {
        Rectangle bnd = bounds();

        /* Create the Control Panel */
        control_panel = new Panel();
        control_panel.setLayout (new FlowLayout (FlowLayout.CENTER));

        cntrl = new ControlItems ();
        control_panel.add (cntrl);



        /* Create the landscape image (for displaying the surfaces) */
        Image back;
        if (ATGRAPH_BACKGROUND.equals (""))
          back = null;
        else
          back = getImage (getCodeBase(), ATGRAPH_BACKGROUND);
        
        land_scape = new MultiPortrait(bnd.width/2-20,(bnd.height*3)/5-18,back); 
        back = current_image;
        land_scape.setImage (back);

        // add the balloon icon to the landscape image
        Image icon = getImage (getCodeBase(), BALLOON);
        waitForImage (this,current_image);
        land_scape.setIcon (icon);




        /* Create pic_panel to hold the landscape image */
        pic_panel = new Panel ();
        pic_panel.setLayout (new FlowLayout (FlowLayout.CENTER));
        pic_panel.add(land_scape);


        
        /* Create the AT Graph */
        if (ATGRAPH_BACKGROUND.equals (""))
          back = null;
        else
          back = getImage (getCodeBase(), ATGRAPH_BACKGROUND);  // set the background

        atgraph = new Graph (bnd.width/2-65 , (bnd.height*3)/5-18,"0000",getGraphics());
        atgraph.setBackground (Color.white);

        if ( back != null )
        {
            atgraph.setImage (back);
        }


        /* Create the graph_panel to hold the ATGraph */
        graph_panel = new Panel ();
        graph_panel.setLayout (new FlowLayout (FlowLayout.CENTER));
        graph_panel.add (atgraph);




        /* Create Graph Control Panel */
        graph_cntrl = new GraphControlItems (0,1,1);

        graph_control_panel = new Panel ();
        graph_control_panel.setLayout(new FlowLayout (FlowLayout.CENTER));
        graph_control_panel.add (graph_cntrl);


        
        /* Create buttons */
        //plotAllButton = new Button("Plot All");



        /*  Layout the screen  */
        GridBagLayout gbl = new GridBagLayout();
        setLayout(gbl);

        add(pic_panel,gbl,1,GridBagConstraints.NORTH);
        //        add(plotAllButton, gbl, 2);
        add(graph_control_panel,gbl,GridBagConstraints.RELATIVE,GridBagConstraints.CENTER);
        add(graph_panel,gbl,GridBagConstraints.REMAINDER,GridBagConstraints.NORTH);
        add(control_panel,gbl,GridBagConstraints.REMAINDER,GridBagConstraints.SOUTHWEST);
      
      }

    public void paint (Graphics g)
      {
        setBackground (Color.lightGray);
        g.drawRect(0,0,size().width-1,size().height-1);
        replot_all_points ();
      }

    public void playStart(Vector values)
    {
        // clear the graph
        init_plotted_points ();
        replot_all_points ();
        
        // update checkboxes
        cntrl.setAlbTime("Sand","Day");
        
        // update image
        int selected_surface_index = 0;
        int day_nite_index = 0;
        current_image = images [selected_surface_index][day_nite_index];
        land_scape.setImage (current_image);
        waitForImage (this,current_image);
        
        // move balloon
        land_scape.resetAltitude();

        // save values
        steps = values;

    }

    public void playStep(int stepIndex)
    {
        Hashtable ht = (Hashtable)steps.elementAt(stepIndex);

        String albedo = (String)ht.get("albedo");
        String time = (String)ht.get("time");
        int alt = (Integer.valueOf((String)ht.get("iconHeight"))).intValue();

        boolean clear = (Boolean.valueOf((String)ht.get("clear"))).booleanValue();

        if (clear)
        {
            // clear the screen
            init_plotted_points ();
            replot_all_points ();
        }
        else
        {
            // run the simulation for values in ht

            // update checkboxes
            cntrl.setAlbTime(albedo,time);
            
            // update image
            int selected_surface_index = cntrl.getSelectedSurfaceIndex();
            int day_nite_index = (cntrl.IsDay())? 0 : 1;
            current_image = images [selected_surface_index][day_nite_index];
            land_scape.setImage (current_image);
            waitForImage (this,current_image);
            
            // move balloon
            land_scape.setAltitude(alt);
            
            // plot the point
            plot (land_scape.getAltitudeIndex());
        }

    }

    public void playClose()
    {
        return;
    }

    public void plot (int index)
      {
        // sets the appropiate cell of the 3D table plotted to true and replots the points
        // Plot altitude[index] vs temperature
       int i1, i2, i3;

       if ( cntrl.IsDay() )
          i1 = 0;
       else
          i1 = 1;

       i2 = cntrl.getSelectedSurfaceIndex();

       i3 = index;

       plotted [i1][i2][i3] = true;
       replot_all_points ();

       int icony = land_scape.getIconY();
       sendData (icony);
       
      }

/*    public void plotAll ()
      {
       // Plot altitude[index] vs temperature
       int i1, i2, i3;

       if ( cntrl.IsDay() )
          i1 = 0;
       else
          i1 = 1;

       i2 = cntrl.getSelectedSurfaceIndex();

       int numAlts = getNumAltitudes();

       for (i3 = 0; i3 < numAlts ; i3++)
       {

           float x = toFarenheit (temperature[i1][i2][i3]);
           float y = ((Float)(altitude.elementAt(i3))).floatValue();

           plotted [i1][i2][i3] = true;

           sendData (x,y);
       }

       replot_all_points ();


      }
*/
    private void print_loaded_values ()
      {
      int i;

      for (i=0; i < pressure.size(); i++)
        {
            System.out.println (((Integer)(pressure.elementAt(i))).intValue()+ " " +
                                ((Float)(altitude.elementAt(i))).floatValue()+ " " +
                                temperature[0][0][i]+ " " +
                                temperature[0][1][i]+ " " +
                                temperature[0][2][i]+ " " +
                                temperature[0][3][i]+ " " +
                                temperature[1][3][i]+ " " +
                                temperature[1][0][i]+ " " +
                                temperature[1][1][i]+ " " +
                                temperature[1][2][i]);
        }
      }

    private void replot_all_points ()
      {
        int i,j,k;
        float x,y;

        if ( atgraph == null )
          return ;
        atgraph.clear();
        for (i=0; i < 2; i++)
          for (j=0; j < cntrl.NUM_SURFACES;j++)
             {
             //if ( graph_cntrl.getSelectedMode().equalsIgnoreCase("Line") )
                 atgraph.setPlotMode (Graph.LINE,colors[j][i][1]);

             for (k=0; k < getNumAltitudes(); k++)
                {
                if (plotted[i][j][k])
                   {
                   //x = k *100 / (getNumAltitudes() - 1);
                   y = ((Float)(altitude.elementAt(k))).floatValue();
                   x = toFarenheit (temperature[i][j][k]);

                   //if ( graph_cntrl.getSelectedMode().equalsIgnoreCase("Point") )
                   //  atgraph.setPlotMode (Graph.POINT,colors[j][i][1]);

                   atgraph.plot (x,y);
                   }
                }
             }
      }

    private void sendData (int icony)
    {

       Hashtable ht = new Hashtable();

       ht.put("albedo", cntrl.getSelectedSurfaceItem());
       ht.put("time", (cntrl.IsDay()) ? "Day" : "Night");
       ht.put("iconHeight", new Integer(icony));
       ht.put("clear", new Boolean(false));

       ar.putValues(ht);

    }

    private void sendData (boolean clearPressed)
    {
        if (clearPressed)
        {
            Hashtable ht = new Hashtable();

            ht.put("albedo", cntrl.getSelectedSurfaceItem());
            ht.put("time", (cntrl.IsDay()) ? "Day" : "Night");
            ht.put("iconHeight", new Integer(-1));
            ht.put("clear", new Boolean(true));

            ar.putValues(ht);
        }

    }



/*            Vector s = ar.getSessions();

            for (int j=0; j<s.size(); j++)
            {
                Date d = (Date) s.elementAt(j);
                System.out.println("\nFor Session " + d);
                Vector v = ar.getValues(d);
                for(int i=0;i< v.size();i++)
                {
                    System.out.println((v.elementAt(i)).toString());
                }
            }
*/

    public void stop ()
    {

        ar.close();

    }

    private float toFarenheit (float kelvin)
    {
        return (float) (kelvin - 273) * 9/5 + 32;
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
