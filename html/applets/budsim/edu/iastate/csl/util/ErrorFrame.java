/*
$Header: /Lessons/util/ErrorFrame.java 2     3/05/99 3:42p Lisa $
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

import java.applet.Applet;
import java.awt.*;

public class ErrorFrame extends Frame 
{
  protected Button closeButton;

  protected Font errorFont = new Font("TimesRoman",Font.BOLD,12);
  protected FontMetrics fm;
  
  protected int errorLabelSize;
  protected Label errorLabel;
  
  protected Panel p1, p2, p3;

  public ErrorFrame() 
  {

    // call base class constructor
    super("Oops");

    // Allocate and add components;
    p1 = new Panel();
    p2 = new Panel();
    
    errorLabel = new Label();
    errorLabel.setAlignment(Label.CENTER);
    errorLabel.setFont(errorFont);
    
    closeButton = new Button ("CLOSE");
    
    p1.add(errorLabel);
    p2.add(closeButton);
    
    add("North",p1);
    add("South",p2);

  }

  public void showMsg(String errMsg) 
  {
    
    int BORDER_SIZE = 20;

    errorLabel.setText(errMsg);
    errorLabelSize = errorLabel.getFontMetrics(errorFont).stringWidth(errMsg);
    resize(errorLabelSize + BORDER_SIZE,125);
    show();

  }

  public boolean handleEvent( Event e ) 
  {
    if ( e.id == Event.WINDOW_DESTROY ) 
    {
      removeSelf();
      return true;
    }
    
    return super.handleEvent( e );
  }

  public boolean action( Event e, Object o ) 
  {
    if ( e.target == closeButton )
      removeSelf();
    return true;
  }

  public void removeSelf() 
  {
    hide();
    dispose();
  }

}
