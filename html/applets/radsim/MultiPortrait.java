/*
$Header: /Lessons/RadSim/MultiPortrait.java 4     12/10/98 2:03p Lisa $
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
import java.applet.Applet;

import edu.iastate.csl.util.Canvas3D;

public class MultiPortrait extends Canvas3D
    {
    protected Image theImage;
    private int MARGIN = 2;
    private Image icon;
    private int iconx,icony, icon_width, icon_height;
    private String altitude_str = new String ("0");
    //private boolean mouse_released;
    private int fromy;  // for dragging the icon

    private Graphics gContext;
    public Image buff;
    private int altitude_percentage;
    private Image actual_image;
//    private boolean new_image;
    private Image graph_back;

    public MultiPortrait(int w,int h,Image graph_background)
      {
        //new_image  = true;
        resize(w,h);

        //mouse_released = true;
        graph_back = graph_background;

      }

    private void create_image ()
      {
      Rectangle r = imageBounds();
      theImage = RadiationSim.me.createImage (r.width,r.height);
      Graphics bg = theImage.getGraphics ();
      bg.setColor (Color.lightGray);
      bg.drawImage (actual_image, 0,0,r.width,r.height,this);
      //drawLegend (bg,r);
      //new_image = false;
      }

/*    private void drawLegend (Graphics g,Rectangle r)
      {
      int rect_width = 35;
      int rect_height = 30;
      int x_origin = r.x+10;
      int y_origin = r.height - rect_height - 10;

      String label = "Graph";
      FontMetrics fm = g.getFontMetrics();

      Color oldColor = g.getColor();
      g.setColor (Color.white);

      if (graph_back == null)
        {
        g.fillRect (x_origin,
                    y_origin,
                    rect_width,
                    rect_height);
        }
      else
        g.drawImage (graph_back,x_origin,y_origin,rect_width,rect_height,this);

      g.setColor (Color.black);
      g.drawString (label,
                    x_origin + (rect_width-fm.stringWidth(label))/2,
                    y_origin + fm.getAscent());

      //System.out.println ("About to set Color");
      g.setColor (RadiationSim.me.getColor(1));

      g.fillRect (x_origin + 5, y_origin + 2 + fm.getAscent(),
                  rect_width-10, rect_height - fm.getAscent()-5);
      //System.out.println ("Filled Rect");
      g.setColor (oldColor);

      }
*/
    public int getIconY()
    {
        return icony;
    }

    public int getAltitudeIndex ()
      {
        int max_altitude_index = RadiationSim.me.getNumAltitudes() - 1;
        int altitude_index = altitude_percentage * max_altitude_index / 100;
        return altitude_index;
      }

    public int getAltitudePercentage()
      {
        return altitude_percentage;
      }

    public Image getImage()
      {
        return theImage;
      }

    public Rectangle imageBounds()
      {
        return new Rectangle(MARGIN,MARGIN,
                             size().width-2*MARGIN,
                             size().height-2*MARGIN);
      }

    //Called when the user clicks
    public boolean mouseDown(Event e, int x, int y)
       {
       //System.out.println ("Down: X=" +x + "; Y=" + y);
       //mouse_released = false;
       fromy = y;
       return true;
       }

    public boolean mouseDrag(Event e, int x, int y)
       {
       /* Move the Balloon along with the Mouse */

       //mouse_released = false;
       if ( x < iconx - icon_width || x > iconx + icon_width  )
         {
          return true;
         }

       Rectangle r = imageBounds();

       int min_altitude = r.y + icon_height;
       int max_altitude = r.height - icon_height;

       int newicony;
       if (y > icony+icon_height + 5 || y < icony - 5) //move icon to mouse
            newicony = y - Math.round((float)(.5 * icon_height));
       else newicony = icony + y - fromy;  //slide icon with mouse

       fromy = y;

       if ( newicony < min_altitude || newicony > max_altitude )
          return true;

       icony = newicony ;

       //g.drawString (altitude_str , r.x + r.width/2 + 10 , r.y + r.height/2);

       //System.out.println (s);

       /*
       gContext.drawImage (theImage,r.x,r.y,r.width,r.height,this);
       gContext.drawImage (icon,iconx,icony,icon_width,icon_height,this);
       */

       repaint ();
       //System.out.println ("Drag: X=" +x + "; Y=" + y);
       return true;
       }

    public boolean mouseUp (Event e, int x, int y)
       {
       //mouse_released = true;
       repaint ();
       return true;
       }

    public void paint(Graphics g)
      {
            super.paint(g);
            Rectangle r = imageBounds();

            //if (new_image)
            this.create_image ();

            if (theImage != null)
              {
              g.drawImage(theImage,r.x,r.y,r.width,r.height,this);
              //drawLegend (g,r);
              //Util.waitForImage (this,theImage);
              //gContext.drawImage(theImage,r.x,r.y,r.width,r.height,this);
              }
            if (icon != null )
              {
                setAltStr(r.y + icon_height,r.height - icon_height,icony);

                g.drawImage (icon, iconx,icony,icon_width,icon_height,this);
              //gContext.drawImage (icon, iconx,icony,icon_width,icon_height,this);
//              if ( !mouse_released )
//                {
                Color old_color;
                FontMetrics fm = g.getFontMetrics();

                old_color = g.getColor();
                int height = fm.getHeight();
                int width = fm.stringWidth(altitude_str);
                g.setColor(Color.white);
                g.fillRect(iconx,icony-height-5,width+1,height+1);
                g.setColor(Color.black);
                g.drawString (altitude_str , iconx + 1 , icony -height - 5 + fm.getAscent());
                g.setColor (old_color);

                /*
                old_color = gContext.getColor();
                gContext.setColor(RadiationSim.me.getColor(0));
                gContext.drawString (altitude_str , r.x + 10 , r.y + r.height/2);
                gContext.setColor (old_color);
                */
//                }
              }

        //g.drawImage (buff,r.x,r.y,r.width,r.height,this);

      }

    public void resize(Dimension d)
      {
        resize(d.width,d.height);
      }

    public void setAltitude(int iconHeight)
    {
        icony = iconHeight;

        Rectangle r = imageBounds();
        int min_altitude = r.y + icon_height;
        int max_altitude = r.height - icon_height;
        altitude_percentage = (int) (100 * (max_altitude - icony)) / (max_altitude - min_altitude);

        repaint();
    }

    public void resetAltitude()
    {
        Rectangle r = imageBounds();
        icony = r.y + r.height/2;
        int min_altitude = r.y + icon_height;
        int max_altitude = r.height - icon_height;
        altitude_percentage = (int) (100 * (max_altitude - icony)) / (max_altitude - min_altitude);

        repaint();
    }

    private void setAltStr(int min_altitude, int max_altitude, int newicony)
    {
       /* Display the altitude */

       int max_altitude_index = RadiationSim.me.getNumAltitudes() - 1;

       altitude_percentage = (int) (100 * (max_altitude - newicony)) / (max_altitude - min_altitude);

       // 0 % => Index = 0; 100 % => Index = max_altitude_index - 1
       // x % => x / 100 * max_altitude_index
       int altitude_index = altitude_percentage * max_altitude_index / 100;

       // Altitude
       String s = "" + (int)RadiationSim.me.getAltitude(altitude_index);
       altitude_str =  s;

    }

    public void setIcon (Image icon_img)
      {
        icon = icon_img;
        Rectangle r = imageBounds();

        icon_width = r.width/16; icon_height=(r.height * 2)/15;
        iconx = r.width/2 + icon_width * 2;
        icony= r.y + r.height/2;

        int min_altitude = r.y + icon_height;
        int max_altitude = r.height - icon_height;
        altitude_percentage = (int) (100 * (max_altitude- icony)) / (max_altitude - min_altitude);

        //gContext.drawImage (icon,iconx,icony,icon_width,icon_height,this);
        repaint ();
      }

    public void setImage(Image img)
      {
        actual_image = img;
        //new_image = true;
        /*
        Rectangle r = imageBounds();
        gContext.drawImage (theImage,r.x,r.y,r.width,r.height,this);
        */
        repaint ();
      }

    public void update (Graphics g)
      {
        this.paint (g);
      }


    }