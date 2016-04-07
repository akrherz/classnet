/*
$Header: /Lessons/RadSim/LabeledPanel.java 3     10/16/98 2:51p Lisa $
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


class LabeledPanel extends Panel
{
    private Label theLabel;
    private Font labelFont;

    private static String fontName = "Helvetica";
    private static int fontSize = 12;
    private static int fontStyle = Font.BOLD;


    LabeledPanel (String label)
    {
        super();
        theLabel = new Label(label);
        labelFont = new Font(fontName, fontStyle, fontSize);

        theLabel.setFont(labelFont);

        add(theLabel);

    }

    public void setTextColor(Color theColor)
    {
        theLabel.setForeground(theColor);
    }

}