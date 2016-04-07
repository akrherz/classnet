/*
$Header: /Lessons/util/GetDataFrame.java 6     3/05/99 4:37p Lisa $
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
import java.util.*;
import edu.iastate.csl.util.AppletRecorder;
import edu.iastate.csl.util.PlayableApplet;
import edu.iastate.csl.util.ErrorFrame;

public class GetDataFrame extends Frame 
{
  protected Button start, step, close;
 
  protected Panel sessionsPanel, buttonsPanel;
  
  protected List sessionList;

  protected PlayableApplet theApplet;
  protected AppletRecorder theAR;
  private   int selection = -1;
  private   int stepIndex = -1;
  private   int numSteps;

  public GetDataFrame(PlayableApplet anApplet, AppletRecorder ar)
  {
    // call base class constructor
    super("Get Student Data");
    theApplet = anApplet;
    theAR = ar;

    resize(212,206);
    start = new Button("Start");
    step = new Button("Step");
    step.disable();
    close = new Button("Cancel");

    makeSessionList();

    buttonsPanel = new Panel();
    buttonsPanel.add( "West", start );
    buttonsPanel.add( "Center", step);
    buttonsPanel.add( "East", close );

    sessionsPanel = new Panel();
    sessionsPanel.resize(150,150);
    sessionsPanel.add("Center",sessionList);

    add("North", new Label("Select a Session:", Label.LEFT));
    add("Center",sessionsPanel);
    add("South",buttonsPanel);

    show();

  }

  public void makeSessionList()
  {

    sessionList = new List(5,false);
    Vector theSessions = theAR.getSessions();
    int size = theSessions.size();

    for (int j =0; j < size; j++)
    {
        Date d = (Date)theSessions.elementAt(j);
        sessionList.addItem(d.toString());
    }

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
    int curCursorType;
    String session;
    Vector values;

    if (e.target == close)
        removeSelf();

    else if (e.target == start)
    {
        selection = sessionList.getSelectedIndex();

        if (selection < 0)
        {
            (new ErrorFrame()).showMsg("Please select a session.");
      	    return true;
        }

        session = sessionList.getSelectedItem();

        curCursorType = getCursorType();
        setCursor(Frame.WAIT_CURSOR);
        values = theAR.getValues(new Date(session));
        numSteps = values.size();
        setCursor(curCursorType);

        theApplet.playStart(values);

        step.enable();
        stepIndex = -1;

    }

    else if (e.target == step)
    {
        int newSelection = sessionList.getSelectedIndex();
        if (selection == newSelection)
        {
            stepIndex++;
            if (stepIndex < numSteps)
                theApplet.playStep(stepIndex);
            else
            {
                (new ErrorFrame()).showMsg("End of session has been reached.  Please select a new session or click cancel.");
                step.disable();
            }
        }
        else if (newSelection < 0)
            (new ErrorFrame()).showMsg("Please select a session.");
        else
            (new ErrorFrame()).showMsg("A session must be selected and started before clicking step.  1) Select a session and press start OR 2) Reselect the session you were stepping through");
    }

    return true;

  }

  public void removeSelf() 
  {
    hide();
    dispose();
  }

}