/*
$Header: /Lessons/util/Portrait.java 3     2/25/99 3:35p Lisa $
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
import java.applet.Applet;

import edu.iastate.csl.util.Canvas3D;

public class Portrait extends Canvas3D {
    protected Image theImage;
    protected Image actual_image;
    protected boolean new_image;
    private int MARGIN = 2;

    public Portrait(int w,int h)
    {
        resize(w,h);
        new_image = true;
    }

    public void paint(Graphics g)
    {
	    super.paint(g);

	    paint_border(g);

	    if (theImage != null) {
	        Rectangle r = imageBounds();
            g.drawImage(theImage,r.x,r.y,r.width,r.height,this);
        }

	}

    private void paint_border(Graphics g)
    {
        Rectangle bnd = bounds();
        g.setColor(Color.black);
        //horizontal black (top)
        g.drawLine(0,0,bnd.width-1, 0);
        g.drawLine(0,1,bnd.width-2, 1);
        //vertical black (Left side)
        g.drawLine(0,0,0,bnd.height-1);
        g.drawLine(1,0,1,bnd.height-2);

        g.setColor(Color.white);
        //horizontal white (bottom)
        g.drawLine(1,bnd.height-1,bnd.width-1,bnd.height-1);
        g.drawLine(2,bnd.height-2,bnd.width-2,bnd.height-2);
        //vertical white (right side)
        g.drawLine(bnd.width-1,0,bnd.width-1,bnd.height-1);
        g.drawLine(bnd.width-2,1,bnd.width-2,bnd.height-2);

    }

    // used for recording path
    public boolean mouseDown(Event e,int x,int y)
    {
        //System.out.println(x+","+y);
        return true;
    }

    public void resize(Dimension d)
    {
        resize(d.width,d.height);
    }

    public void setImage(Image img)
    {
        //System.out.println ("Set Image Called");
        theImage = img;
        actual_image = img;
        new_image = true;
        repaint ();
    }

    public Image getImage() { return theImage; }

    public Rectangle imageBounds()
    {
        return new Rectangle(MARGIN,MARGIN,
                             size().width-2*MARGIN,
                             size().height-2*MARGIN);
    }
}
