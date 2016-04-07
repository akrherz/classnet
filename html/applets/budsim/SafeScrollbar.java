/*
$Header: /Lessons/MtnSim/SafeScrollbar.java 2     3/09/99 4:16p Lisa $
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

public class SafeScrollbar extends Scrollbar
{
    public int max = 314;

    public SafeScrollbar()
    {
        super();
    }

    public SafeScrollbar(int orientation)
    {
        super(orientation);
    }

    public SafeScrollbar(int orientation, int value, int visible, int minimum, int maximum)
    {
        super(orientation, value, visible, minimum, maximum);
    }

    public synchronized void setValue(int  value)
    {
        if (value<max)
        {
            super.setValue(value);
            //System.out.println("value<max");
        }
        else
        {
            super.setValue(max);
            //System.out.println("value >= max");
        }
    }

}