/*
$Header: /Lessons/util/Axis.java 4     3/05/99 3:35p Lisa $
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

public class Axis extends Object {
    private Point org; 
    private Dimension dim; 
    private String label = "";
    private Font labelFont = new Font("Helvetica",Font.BOLD,10);
    private boolean vertical = false;
    private double scale = 1.0;
    public double min = 0.0;
    public double max = 0.0;
    private double major = 10.0;
    private double minor = 1.0;
    private int scale_type = 0;

    public static int HORIZONTAL=0;
    public static int VERTICAL=1;

    public static int LINEAR_SCALE=0;
    public static int LOG_SCALE=1;
    private String MAX_LENGTH_Y_AXIS_VALUE;

    private Color labelColor = Color.blue;

    public Axis(int orient, int x, int y, int w, int h)
    {
        vertical = orient == VERTICAL;
        org = new Point(x,y); 
        dim = new Dimension(w,h);
    }

    public void setBounds(double aMin,double aMax,double aMajor,double aMinor)
    {
        min = aMin;
        max = aMax;
        major = aMajor;
        minor = aMinor;
        if (vertical)
            scale = dim.height/(max - min);
        else
            scale = dim.width/(max - min);
    }

    public void setLabel(String aLabel) { label = aLabel; }

    public void setFont(Font aFont) { labelFont = aFont; }

    public void setLabelColor(Color theLabelColor) { labelColor = theLabelColor; }

    public void paint(Graphics g)
    {
        g.setFont(labelFont);
        FontMetrics fm = g.getFontMetrics();
        g.setColor(Color.black);
        if (vertical) 
        {
            g.drawLine(org.x,org.y,org.x,org.y + dim.height);
            
            for (double val=min+major; val <= max; val += major) 
            {
                int v = getLoc(val);
                g.drawLine(org.x-3,v,org.x+3,v);
                
                int temp = (int)val * 10;
                String s = String.valueOf((int)temp/10);
                g.drawString(s,org.x-3-fm.stringWidth(s),v+fm.getAscent()/2);
            }

            g.setColor(labelColor);
            g.drawString(label, 3, fm.getAscent());
        } 
        else // horizontal
        {
            g.drawLine(org.x,org.y,org.x + dim.width,org.y);
            
            for (double val=min+major; val <= max; val += major) 
            {
                int v = getLoc(val);
                g.drawLine(v,org.y-3,v,org.y+3);
                
                int temp = (int)val * 10;
                String s = String.valueOf((int)temp/10);
                g.drawString(s,v-fm.stringWidth(s)/2,org.y+4+fm.getAscent());
            }
            
            g.setColor(labelColor);
            
            int x = (dim.width - fm.stringWidth(label))/2;
            g.drawString(label,org.x+x,org.y + 27);
        }
    }

    public void reshape(int x,int y,int w,int h)
    {
        if (vertical)
            scale = dim.height/(max - min);
        else
            scale = dim.width/(max - min);
    }

    public int getLoc(double val)
    {
        int ival;

        if (scale_type == LINEAR_SCALE)
            ival = (int)(scale*(val-min));
        else
            ival = (int)Math.log(scale*(val-min));
        return(vertical?org.y + dim.height - ival:org.x + ival);
    }

    public double getValue(int v)
    {
        if (vertical)
            return min + (max - min) * (dim.height - (v - org.y))/dim.height;
        else
            return min + (max - min) * (v - org.x)/dim.width;
    }

    public boolean inside(int v)
    {
        if (vertical)
            return v >= org.y && v <= (org.y + dim.height);
        else
            return v >= org.x && v <= (org.x + dim.width);
    }
}
