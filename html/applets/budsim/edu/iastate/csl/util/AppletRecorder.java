/*
$Header: /Lessons/util/AppletRecorder.java 13    3/05/99 4:37p Lisa $
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
import java.io.*;
import java.net.*;
import java.awt.*;
import java.util.*;

public class AppletRecorder
{
    public static int SERVER_PORT = 6871;
    public String host = "classnet.geol.iastate.edu";

    private Socket theSocket;
    private DataInputStream input;
    private DataOutputStream output;
    private boolean conopen = false;

    // applet parameters
    private String mode;
    private String filePath;

    // storage for data from the server when in record mode
    private Vector sessions = null;  // Vector of session dates
    private Hashtable values = null; // key is session date;
                                     // value is vector containing hashtables
                                     //            where each hashtable is an event

    public AppletRecorder()
    {
        super();
        sessions = new Vector();
        values = new Hashtable();
    }

    public void close()
    {   
        // closes the server connection regardless of mode
        try
        {
            if (conopen)
            {
                output.flush();
                output.close();
                theSocket.close();
            }
        }
        catch (IOException e)
        {
            System.out.println("Problem in close");
        }
    }

    public Vector getSessions()
    {   // returns a vector of sessions dates when in play mode
        // returns null when in record mode

        if (!conopen) return null;
        else if (mode.equalsIgnoreCase("play"))
        {
            return sessions;
        }
        else return null;
    }

    public Vector getValues(Date d)
    {   
        // returns a vector of hashtables for the given date
        // each hashtable corresponds to one event
        // NOTE: the hashtable consists entirely of strings
        //       you must convert the string back to whatever datatype you want
        // returns null when in record mode

        if (!conopen) return null;
        if (mode.equalsIgnoreCase("play"))
        {
            Vector v = (Vector)values.get(d);
            return (Vector)v;
        }
        else return null;

    }

    public void open(String theFilePath, String theMode, Applet app)
    {
        // make connection with the server in the given mode
        // app is assumed to implement PlayableApplet when open is called in play mode!

      mode = theMode;
      filePath = theFilePath;

      if (!mode.equalsIgnoreCase("demo"))
      {
        try
        {
            theSocket = new Socket(host, SERVER_PORT);
            conopen = true;

            input = new DataInputStream(
                        new BufferedInputStream(theSocket.getInputStream()));
            output = new DataOutputStream(
                        new BufferedOutputStream(theSocket.getOutputStream()));

            output.writeChars(mode + '\n');
            output.writeChars(filePath + '\n');
            output.flush();

            if (mode.equalsIgnoreCase("play"))
            {
                readInput();
                new GetDataFrame((PlayableApplet)app, this);
            }                

        }
        catch (IOException e)
        {
            // socket connection not established
            (new ErrorFrame()).showMsg("Connection with server could not be made: Data cannot be saved or retrieved.");
            System.out.println("IOException in opening Connection: Data cannot be saved or retrieved.");
        }

      }

    }

    public void putValues(Hashtable table)
    {   // stores the values on the server as an event line
        // does nothing when mode is "record"
        if (!conopen) return;
        if (mode.equalsIgnoreCase("record"))
        {
            try
            {
                output.writeChars("event " + table.toString() + '\n');
            }
            catch (IOException e)
            {
                //System.out.println("Problem in putValues");
                e.printStackTrace();
            }

        }

    }

    private void readInput()
    {   // stores the session data from the server into the
        // vector sessions and the hashtable values
        // assumes socket connection is open

        String s = "";
        String scode = new String("");
        Date sdate = new Date();
        String skey = new String("");
        String svalue = new String("");

        // read code word
        scode = readWord();

        while (scode != null)
        {

            if (scode.equalsIgnoreCase("session"))
            {
                // read session date
                sdate = new Date(readUntil('\n')); 

                // store session date
                sessions.addElement(sdate);
                values.put(sdate, new Vector());

            }
            else if (scode.equalsIgnoreCase("event"))
            {
                // read event
                Hashtable ht = new Hashtable();

                //read key
                skey = readUntil('=');

                while (skey != "\n")
                {
                    //read value
                    svalue = readUntil(',','}');

                    // add key,value pair
                    ht.put(skey,svalue);
                    //read key
                    skey = readUntil('=');

                }


                Vector v = (Vector)values.get(sdate);  // get vector of events for this date
                values.remove(sdate);                  // remove that vector
                v.addElement(ht);
                values.put(sdate, v);                  // replace that vector with the
                                                       // new vector containing ht
            }

            // read code word
            scode = readWord();
        }

    }

    private String readUntil(char stop)
    {
        // returns string that is formed from:
        // skip leading spaces,brackets,commas, and equals  then return string before stop
        // the readUntil(stop) method will return the string "\n" if it is the
        // first non-whitespace (defined above) char read

        char ch;
        String s = new String("");

        try
        {
            ch = input.readChar();
            while ((ch == ' ') || (ch == '{') || (ch == '}') || (ch == ',') || (ch == '='))
            {
                ch = input.readChar();
            }

            if (ch == '\n')
            {
                return ("\n");
            }

            while (ch != stop)
            {
                s = s + ch;
                ch = input.readChar();
            }
        }
        catch (EOFException e)
        {
            return null;
        }
        catch (IOException e)
        {
            //System.out.println("Caught IOException in readUntil method of AppletRecorder");
            e.printStackTrace();
        }

        //System.out.println("This string has been read: " + s);
        return s;
    }


    private String readUntil(char stop1, char stop2)
    {
        // returns string that is formed from:
        // skip leading spaces,brackets,commas, and equals  then return string before stop
        // the readUntil(stop) method will return the string "\n" if it is the
        // first non-whitespace (defined above) char read

        char ch;
        String s = new String("");

        try
        {
            ch = input.readChar();
            while ((ch == ' ') || (ch == '{') || (ch == '}') || (ch == ',') || (ch == '='))
            {
                ch = input.readChar();
            }

            if (ch == '\n')
            {
                //System.out.println("This string has been read:  End of Line");
                return ("\n");
            }

            while ((ch != stop1) && (ch != stop2))
            {
                s = s + ch;
                ch = input.readChar();
            }
        }
        catch (EOFException e)
        {
            return null;
        }
        catch (IOException e)
        {
            //System.out.println("Caught IOException in readUntil method of AppletRecorder");
            e.printStackTrace();
        }

        //System.out.println("This string has been read: " + s);
        return s;
    }


    private String readWord()
    {
        // reads past whitespace which is: leading spaces, left brackets,
        //                                 right brackets, equals, and commas
        // the readWord() method will return the string "\n" if it is the
        // first non-whitespace (defined above) char read

        char ch;
        String s = new String("");

        try
        {
            ch = input.readChar();

            while ((ch == ' ') || (ch == '{') || (ch == '}') || (ch == ',') || (ch == '='))
            {
                ch = input.readChar();
            }

            if (ch == '\n')
            {
                //System.out.println("This string has been read:  End of Line");
                return ("\n");
            }

            while ((ch != ' ') && (ch != '{') && (ch != '}') && (ch != ',') && (ch != '=') && (ch != '\n'))
            {
                s = s + ch;
                ch = input.readChar();
            }

        }
        catch (EOFException e)
        {
            return null;
        }
        catch (SocketException e)
        {
            conopen = false;
            return null;
        }
        catch (IOException e)
        {
            //System.out.println("Caught IOException in readWord method of AppletRecorder");
            e.printStackTrace();
            return null;
        }

        //System.out.println("This string has been read: " + s);
        return s;

    }

}

/*

Example code to place in an applet to use the AppletRecorder:
**************************************************************

private AppletRecorder ar;
private String filepath;
private String mode;
private GetDataFrame gdf;
private Vector steps;

public void init ()
      {
        ar = new AppletRecorder();
        filepath = getParameter("filepath");
        mode = getParameter("mode");
        ar.open(filepath, mode, this);
      }

public void stop ()
        {
            ar.close();
        }

need to sendData similar to this:
private void sendData (int icony)
    {

       Hashtable ht = new Hashtable();

       ht.put("albedo", cntrl.getSelectedSurfaceItem());
       ht.put("time", (cntrl.IsDay()) ? "Day" : "Night");
       ht.put("iconHeight", new Integer(icony));
       ht.put("clear", new Boolean(false));

       ar.putValues(ht);

    }

*/
