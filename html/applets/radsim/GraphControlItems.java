/*
$Header: /Lessons/RadSim/GraphControlItems.java 6     11/19/98 8:16p Lisa $
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

public class GraphControlItems extends Panel
  {
    private Button plot,clear;
    //private CheckboxGroup plot_mode;
    //private Checkbox plot_line;
    //private Checkbox plot_point;

    private int down;
    private int left;
    private int right;

    GraphControlItems (int pushdown, int indentleft, int indentright)
      {
        down = pushdown;
        left = indentleft;
        right = indentright;

        plot = new Button ("Plot");
        clear = new Button ("Clear");

        //plot_mode = new CheckboxGroup();

        //plot_line = new Checkbox("Line", plot_mode, true);
        //plot_point = new Checkbox("Point", plot_mode, false);

        //LabeledPanel plot_mode_panel = new LabeledPanel ("Graph Type");
        //plot_mode_panel.setLayout(new GridLayout(0,1));
        //plot_mode_panel.add (plot_line);
        //plot_mode_panel.add (plot_point);


        // layout the graph controls
        GridBagLayout gbl = new GridBagLayout();
        setLayout (gbl);

        add (plot,gbl,GridBagConstraints.RELATIVE,1,down,0,0);
        //add (plot_mode_panel,gbl,GridBagConstraints.REMAINDER,2,0,1,0);
        add (clear,gbl,1,GridBagConstraints.RELATIVE,30,0,1);

      }

    private void add (Component c, GridBagLayout gbl, int gw, int gh, int pushDown, int gx, int gy)
    {
        GridBagConstraints gbc = new GridBagConstraints();

        gbc.anchor = GridBagConstraints.NORTH;
        gbc.insets = new Insets(pushDown,left,0,right);
        gbc.gridwidth = gw;
        gbc.gridheight = gh;
        gbc.gridx = gx;
        gbc.gridy = gy;

        gbl.setConstraints(c,gbc);

        add (c);
    }

    Button getPlotButton ()
      {
        return plot;
      }

    Button getClearButton ()
      {
        return clear;
      }

    //Checkbox getPlotLine ()
    //  {
    //    return plot_line ;
    //  }

    //Checkbox getPlotPoint ()
    //  {
    //    return plot_point;
    //  }

    //String getSelectedMode ()
    //  {
    //    return plot_mode.getCurrent ().getLabel().trim();
    //  }
  }