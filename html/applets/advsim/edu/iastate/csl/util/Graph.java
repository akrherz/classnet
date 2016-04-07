/*
$Header: /Lessons/util/Graph.java 4     3/05/99 4:32p Lisa $
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

package edu.iastate.csl.util;

import java.awt.*;
import edu.iastate.csl.util.Axis;

public class Graph extends edu.iastate.csl.util.Portrait 
{
    protected Axis xAxis;
    protected Axis yAxis;
    protected Point last;
    private int mode = 0;
    private Color plotColor = Color.black;

    static int X=0;
    static int Y=1;

    // plot mode
    public static int POINT = 0;
    public static int LINE = 1;

    static int LEFTMARGIN = 20;
    static int BOTTOMMARGIN = 40;
    static int RIGHTMARGIN = 10;

    static int TEXTHEIGHT = 18;

    Rectangle xAxisCoods, yAxisCoods;

    public Graph(int w, int h)
    {
        super(w,h);

        setxAxisCoods (w,h);
        setyAxisCoods (w,h);

    }

    public Graph(int w, int h, String s, Graphics g)
    {   
        // s is of format "000" which is the largest Y unit label.
        super(w,h);

        FontMetrics fm = g.getFontMetrics();

        TEXTHEIGHT = 4 + fm.getAscent();
        LEFTMARGIN = 10 + fm.stringWidth(s);
        RIGHTMARGIN = 10;
        BOTTOMMARGIN = 2 * TEXTHEIGHT + 5;

        setxAxisCoods (w,h);
        setyAxisCoods (w,h);

    }

    private void setxAxisCoods(int w, int h)
    {
        xAxisCoods = new Rectangle (LEFTMARGIN,h-BOTTOMMARGIN,w-LEFTMARGIN-RIGHTMARGIN,BOTTOMMARGIN);
        xAxis = new Axis(Axis.HORIZONTAL,
                                    LEFTMARGIN,h-BOTTOMMARGIN,w-LEFTMARGIN-RIGHTMARGIN,BOTTOMMARGIN);
    }

    private void setyAxisCoods(int w, int h)
    {
        yAxisCoods = new Rectangle (LEFTMARGIN,TEXTHEIGHT,LEFTMARGIN,h-BOTTOMMARGIN-TEXTHEIGHT);
        yAxis = new Axis(Axis.VERTICAL,
                                    LEFTMARGIN,TEXTHEIGHT,LEFTMARGIN,h-BOTTOMMARGIN-TEXTHEIGHT);
    }

    public Rectangle getxAxisCoods ()
    {
        return xAxisCoods;
    }

    public Rectangle getyAxisCoods ()
    {
        return yAxisCoods;
    }

    public void setLabels(String xlab,String ylab)
    {
        xAxis.setLabel(xlab);
        yAxis.setLabel(ylab);
    }

    public void setLabelColors(Color xColor, Color yColor)
    {
        xAxis.setLabelColor(xColor);
        yAxis.setLabelColor(yColor);
    }

    public void setXBounds(double aMin,double aMax,double aMajor,double aMinor)
    {
        xAxis.setBounds(aMin,aMax,aMajor,aMinor);
    }

    public void setYBounds(double aMin,double aMax,double aMajor,double aMinor)
    {
        yAxis.setBounds(aMin,aMax,aMajor,aMinor);
    }

    public void setPlotMode(int aMode,Color aColor)
    {
        if (aMode == POINT || aMode == LINE) {
            mode = aMode;
            last = null;
            plotColor = aColor;
        }
    }

    public void setColor (Color aColor)
    {
        plotColor = aColor;
    }

    private void create_image (Graphics g)
    {
        Rectangle r = imageBounds();
        new_image = false;

        theImage = createImage(r.width,r.height);
        Graphics bg = theImage.getGraphics();

        if (actual_image == null) 
        {
            // System.out.println ("No Back Image");
            bg.setColor(new Color(252,250,248));
            bg.fillRect(0,0,r.width,r.height);

        }
        else
        {
            Image temp = actual_image;
            bg.drawImage (temp,0,0,r.width,r.height,this);
        }

        xAxis.paint(bg);
        yAxis.paint(bg);
    }

    public void update (Graphics g)
    {
        this.paint (g);
    }

    public void paint(Graphics g)
    {
       if (new_image)
         this.create_image (g);
 
       super.paint(g);
    }

    public void plot(double xval, double yval)
    {
        plotBuffer(xval,yval);
	    Rectangle r = imageBounds();
        getGraphics().drawImage(theImage,r.x,r.y,r.width,r.height,this);
    }

    public void clear()
    {
        Rectangle r = imageBounds();

        if ( theImage == null )
          return ;

        if (new_image)
          return;

        Graphics bg = theImage.getGraphics();
        create_image (bg);
        bg.drawImage (theImage,0,0,r.width,r.height,this);
        xAxis.paint(bg);
        yAxis.paint(bg);

        //System.out.println ("Clearing .. ");
        repaint();
    }

    protected void drawMarker(Graphics g,int x,int y)
    {
        g.setColor(plotColor);
        g.setXORMode(Color.white);
        g.fillRect(x-2,y-2,4,4);
        g.setPaintMode();
    }

    protected void plotBuffer(double xval,double yval)
    {
        if (xval >= xAxis.min && xval <= xAxis.max &&
            yval >= yAxis.min && yval <= yAxis.max) 
            {                
                int x = xAxis.getLoc(xval);
                int y = yAxis.getLoc(yval);
            
                Graphics g = theImage.getGraphics();
                g.setColor(plotColor);
            
                if (last == null) 
                {
                    g.drawLine(x,y,x,y);
                    last = new Point(x,y);
                    drawMarker(g,x,y);
                } 
                else 
                {
                    drawMarker(g,last.x,last.y);
                    if (mode == POINT)
                        g.drawLine(x,y,x,y);
                    else
                        g.drawLine(last.x,last.y,x,y);
                    last.move(x,y);
                    drawMarker(g,x,y);
                }
            }
    }
}
