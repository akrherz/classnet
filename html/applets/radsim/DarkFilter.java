/*
$Header: /Lessons/RadSim/DarkFilter.java 2     10/14/98 5:28p Lisa $
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

class DarkFilter extends RGBImageFilter {
    public DarkFilter()
    {
	// setting this to true will cause the filter to call filterRGB
	// for every color in the pallette rather than for each pixel
	// (x,y values in filterRGB are meaningless in this case)
	// This will result in fast rendering.
        canFilterIndexColorModel = true;
    }

    public int filterRGB(int x,int y,int rgb) {
	// return a darker color of rgb
	// The following is quick and dirty but not efficient
	// it would be better to strip out the r,g and b values, darken
	// them and return the new color.
	Color c = new Color(rgb);
	return (c.darker().darker().darker().getRGB());
    }
}


