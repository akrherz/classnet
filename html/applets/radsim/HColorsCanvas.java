/*
$Header: /Lessons/RadSim/HColorsCanvas.java 2     10/23/98 2:02p Lisa $
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

public class HColorsCanvas extends Canvas
{
    private int numColors;
    private boolean[] raised;

    private static int COLORSPACE = 64;  // width for the space for each color
    private static int COLORHEIGHT = 14; // number pixels high that are colored
    private static int COLORWIDTH = 20;  // number pixels wide the color is
    private static int LEFTMARGIN = 20;   // space left of first color
    private Color[] theColors;

    private Component receiver;

    public static int COLORPRESSED = 0;


    HColorsCanvas(int n, Color[] colors, Component theReceiver)
    {
        super();

        resize(LEFTMARGIN + COLORSPACE * n, COLORHEIGHT + 7);
        numColors = n;
        theColors = colors;

        boolean[] allFalse= {false,false,false,false};
        raised = allFalse;

        receiver = theReceiver; //for receiving the mouse events
    }

    public void paint(Graphics g)
    {
        super.paint(g);

        int w = size().width;
        int h = size().height;

        for (int i = 0; i < numColors; i++)
        {
            g.setColor(theColors[i]);
            int x = LEFTMARGIN + COLORSPACE * i;
            int y = 3;
            g.fill3DRect(x, y, COLORWIDTH, COLORHEIGHT, true);
            if (raised[i] == true)
            {
                g.setColor(Color.white);
                g.drawRect(x-2,y-2,COLORWIDTH + 4,COLORHEIGHT + 4);
                g.drawRect(x-1,y-1,COLORWIDTH + 2,COLORHEIGHT + 2);

                g.setColor(Color.gray);
                g.drawRect(x-3,y-3,COLORWIDTH + 6,COLORHEIGHT + 6);
            }
        }
    }

    public void setRaised(boolean[] newRaised)
    {
        raised = newRaised;

        repaint();
    }

    public boolean mouseDown(Event evt, int x, int y)
    {
      // yval is the number 1-4 of which color's colorspace was clicked on
      int xval = ((x-LEFTMARGIN) / COLORSPACE) + 1;

      if ((x-LEFTMARGIN > 0) && (xval <= numColors))
      {

        // onColor is true when the click is in the portion of the colorspace that
        // is colored.
        boolean onColor = (((x-LEFTMARGIN) % COLORSPACE) <= COLORWIDTH )? true:false;

        if (onColor)
        {
           receiver.postEvent(new Event(this,COLORPRESSED, new Integer(xval)));
           return true;
        }
      }
      return (false);

    }
}