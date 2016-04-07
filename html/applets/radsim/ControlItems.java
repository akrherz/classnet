/*
$Header: /Lessons/RadSim/ControlItems.java 13    12/15/98 6:27p Lisa $
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
import java.awt.*;

public class ControlItems extends Panel
  {
    private ColorsCanvas day_colors;
    private ColorsCanvas night_colors;
    private Panel colors_panel;

    private CheckboxGroup surface;
    private Checkbox cs0;
    private Checkbox cs1;
    private Checkbox cs2;
    private Checkbox cs3;
    private LabeledPanel csurface_panel;

    private int surfaceIndex;
    private Panel surface_panel;

    private CheckboxGroup day_nite;
    private Checkbox cday;
    private Checkbox cnight;
    private LabeledPanel cday_nite_panel;

    private int dayNightIndex;
    private LabeledPanel day_nite_panel;

    // define surface types that will be used
    public String[] surface_types = {"Sand", "Plowed Field", "Grass", "Fresh Snow"};

    // define surface indexes
    public int SAND = 0;
    public int PLOWED_FIELD = 1;
    public int GRASS = 2;
    public int FRESH_SNOW = 3;

    public static int NUM_SURFACES = 4;

    public static int COLORCHANGED = 0;  // event id


    ControlItems ()
      {
        // Daytime Colors
        Color[] theDayColors = {RadiationSim.getPlotColor(0,0), RadiationSim.getPlotColor(1,0),
                                RadiationSim.getPlotColor(2,0), RadiationSim.getPlotColor(3,0)};
        day_colors = new ColorsCanvas(4,theDayColors,this);

        // Nighttime Colors
        Color[] theNightColors = {RadiationSim.getPlotColor(0,1), RadiationSim.getPlotColor(1,1),
                                  RadiationSim.getPlotColor(2,1), RadiationSim.getPlotColor(3,1)};
        night_colors = new ColorsCanvas(4,theNightColors,this);

        Label day = new Label("Day",Label.CENTER);
        Label night = new Label("Night",Label.CENTER);

        // layout the colors_panel
        colors_panel = new Panel();
        GridBagLayout cgbl = new GridBagLayout();
        colors_panel.setLayout(cgbl);
        GridBagConstraints cgbc = new GridBagConstraints();

        cgbc.gridwidth = GridBagConstraints.RELATIVE;
        cgbl.setConstraints(day, cgbc);
        colors_panel.add(day);

        cgbc.gridwidth = GridBagConstraints.REMAINDER;
        cgbl.setConstraints(night, cgbc);
        colors_panel.add(night);

        cgbc.gridwidth = GridBagConstraints.RELATIVE;
        cgbl.setConstraints(day_colors, cgbc);
        colors_panel.add(day_colors);

        cgbc.gridwidth = GridBagConstraints.REMAINDER;
        cgbl.setConstraints(night_colors, cgbc);
        colors_panel.add(night_colors);

        // setup the surface type labels
        surface_panel = new Panel ();
        surface_panel.setLayout (new GridLayout(0,1));

        surface_panel.add (new Label ("", Label.RIGHT));
        surface_panel.add (new Label (surface_types[0], Label.RIGHT));
        surface_panel.add (new Label (surface_types[1], Label.RIGHT));
        surface_panel.add (new Label (surface_types[2], Label.RIGHT));
        surface_panel.add (new Label (surface_types[3], Label.RIGHT));

        // Setup the day/night checkboxes
        day_nite = new CheckboxGroup ();
        cday = (new Checkbox ("Day", day_nite, true));
        cnight = (new Checkbox ("Night", day_nite, false));

        cday_nite_panel = new LabeledPanel("Time of Day");
        cday_nite_panel.setLayout (new GridLayout(0,1));
        cday_nite_panel.add(cday);
        cday_nite_panel.add(cnight);

        // Setup the surface checkboxes
        csurface_panel = new LabeledPanel ("Surface Type");
        csurface_panel.setLayout (new GridLayout(0,1));

        surface = new CheckboxGroup ();
        cs0 = new Checkbox (surface_types[0], surface, true);
        cs1 = new Checkbox (surface_types[1], surface, false);
        cs2 = new Checkbox (surface_types[2], surface, false);
        cs3 = new Checkbox (surface_types[3], surface, false);
        csurface_panel.add(cs0);
        csurface_panel.add(cs1);
        csurface_panel.add(cs2);
        csurface_panel.add(cs3);
        // the following statements had no effect
        //cs0.setBackground(Color.lightGray);
        //cs1.setBackground(Color.lightGray);
        //cs2.setBackground(Color.lightGray);
        //cs3.setBackground(Color.lightGray);

        csurface_panel.setBackground(Color.lightGray);

/*        csurface_panel.add (new Checkbox (surface_types[0], surface, true));
        for (int cntr = 1; cntr < NUM_SURFACES; cntr ++)
        {
            csurface_panel.add (new Checkbox (surface_types[cntr], surface, false));
        }
*/
        // Set up the screen layout
        GridBagLayout gbl = new GridBagLayout();
        setLayout (gbl);

        add(csurface_panel,gbl,1,1,40,20);
        add(cday_nite_panel,gbl,1,1,20,20);

//        add(surface_panel,gbl,GridBagConstraints.REMAINDER,1,90,0);
//        add(colors_panel,gbl,GridBagConstraints.REMAINDER,1,40,0);

        add(surface_panel,gbl,GridBagConstraints.RELATIVE,1,85,5);
        add(colors_panel,gbl,GridBagConstraints.REMAINDER,1,5,15);

        update((IsDay()? 0 : 1), getSelectedSurfaceIndex());

      }


    private void add(Component c,GridBagLayout gbl,int gw, int gh, int lgap, int rgap)
      {
        GridBagConstraints gbc = new GridBagConstraints();

        gbc.gridwidth = gw;
        gbc.gridheight = gh;
        gbc.anchor = GridBagConstraints.NORTHWEST;

	    gbc.insets = new Insets(0,lgap,0,rgap);

        gbl.setConstraints(c,gbc);
        add(c);
      }


    int getSelectedSurfaceIndex ()
      {

        return (surfaceIndex);

        // returns a value one greater than NUM_SURFACES if nothing is selected
/*
        Checkbox cb = surface.getCurrent();

        boolean found = false;
        int cntr = 0;

        while (!found && (cntr < NUM_SURFACES))
        {
            if ( cb.getLabel().equalsIgnoreCase (surface_types[cntr]))
                found = true;
            else cntr++;
        }

        return cntr;
        */
      }

    String getSelectedSurfaceItem ()
      {

        return surface_types[getSelectedSurfaceIndex()];

      }

    public boolean handleEvent(Event e)
    {/*  this code is for allowing clicks on the colors
        if ((e.target == day_colors) && (e.id == ColorsCanvas.COLORPRESSED))
        {
            update(0, ((Integer)(e.arg)).intValue() - 1);
            RadiationSim.me.postEvent(new Event(this,COLORCHANGED,null));
            return(true);
        }

        else if ((e.target == night_colors) && (e.id == ColorsCanvas.COLORPRESSED))
        {
            update(1, ((Integer)e.arg).intValue() - 1);
            RadiationSim.me.postEvent(new Event(this,COLORCHANGED,null));
            return(true);
        }
      */

        if (e.target instanceof Checkbox)
        {
            if ((e.target == cday) || (e.target == cnight))
            {
                Checkbox cb = day_nite.getCurrent();
                if (cb.getLabel().equalsIgnoreCase ("Day"))
                    update (0,surfaceIndex);
                else if (cb.getLabel().equalsIgnoreCase ("Night"))
                    update (1,surfaceIndex);
            }

            else // checkbox must be one of surfaces
            {
                Checkbox cb = surface.getCurrent();

                boolean found = false;
                int cntr = 0;
                while (!found && (cntr < NUM_SURFACES))
                {
                    if ( cb.getLabel().equalsIgnoreCase (surface_types[cntr]))
                        found = true;
                    else cntr++;
                }

                update(dayNightIndex, cntr);
            }

            RadiationSim.me.postEvent(new Event(this,COLORCHANGED,null));
            return(true);
        }

        else
        {
            return (false);
        }

    }

    boolean IsDay ()
      {
        if (dayNightIndex == 0)
        {
            return true;
        }
        else
        {
            return false;
        }
/*        Checkbox cb = day_nite.getCurrent();

        if ( cb.getLabel().equalsIgnoreCase ("Day"))
           return true;

        return false;
        */
      }

    public void setAlbTime( String albedo, String time )
    {
        int surf=-1;
        int dn=-1;

        Checkbox csurf = null;
        Checkbox cdn = null;

        // determine which surface type albedo is
        if (cs0.getLabel().equalsIgnoreCase(albedo))
            { csurf = cs0; surf = 0; }
        else if (cs1.getLabel().equalsIgnoreCase(albedo))
            { csurf = cs1; surf = 1; }
        else if (cs2.getLabel().equalsIgnoreCase(albedo))
            { csurf = cs2; surf = 2; }
        else if (cs3.getLabel().equalsIgnoreCase(albedo))
            { csurf = cs3; surf = 3; }
        else System.out.println("Bad surface type in ControlItems.setAlbTime");

        // determine which time time is
        if (time.equalsIgnoreCase ("Day"))
            { dn = 0; cdn = cday; }
        else if (time.equalsIgnoreCase ("Night"))
            { dn = 1; cdn = cnight; }
        else System.out.println("bad Day-Night value in ControlItems.setAlbTime");

        // call update to change raised color boxes
        update(dn, surf);

        // update the checkboxes
        day_nite.setCurrent(cdn);
        surface.setCurrent(csurf);


    }

    public void update (int day_nite_index, int selected_surface_index)
      {
        // day = 0; night = 1
        dayNightIndex = day_nite_index;
        surfaceIndex = selected_surface_index;

        boolean[] allFalse = {false,false,false,false};
        boolean[] temp = {false,false,false,false};

        if (day_nite_index == 0)
        {
            night_colors.setRaised(allFalse);
            temp[selected_surface_index] = true;
            day_colors.setRaised(temp);
        }
        else
        {
            day_colors.setRaised(allFalse);
            temp[selected_surface_index] = true;
            night_colors.setRaised(temp);
        }

      }
  }