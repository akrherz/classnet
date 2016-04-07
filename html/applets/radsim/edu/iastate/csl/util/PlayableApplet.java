
package edu.iastate.csl.util;

import java.util.*;

public interface PlayableApplet
{
    public abstract void playStart(Vector values);
    public abstract void playStep(int valueIndex);
    public abstract void playClose();
}

/* 

Example code of how to make an applet playable
************************************************

public void playStart(Vector values)
    {
       // clear the screen
       // initialize values (remember that this will be called also when the prof 
       //                                               changes between sessions)
       // save values for later user
	steps = values;
    }

public void playStep(int stepIndex)
    {
	// get the hashtable of values
        Hashtable ht = (Hashtable)steps.elementAt(stepIndex);

	// convert the strings that are in the hashtable to the proper type
        String albedo = (String)ht.get("albedo");
        String time = (String)ht.get("time");
        float temp = (Float.valueOf((String)ht.get("temperature"))).floatValue();
        float alt = (Float.valueOf((String)ht.get("altitude"))).floatValue();
        
        double temp = (Double.valueOf((String)ht.get("temperature"))).doubleValue();
        double pressure = (Double.valueOf((String)ht.get("pressure"))).doubleValue();
        boolean clear = (Boolean.valueOf((String)ht.get("clear"))).booleanValue();

        if (clear)
        {
            // clear the screen
        }
        else
        {
            // run the simulation for the values 
        }
    }

public void playClose()
    {
	// may do nothing
	// do any cleanup that you want to do for when the window closes
    }



*/