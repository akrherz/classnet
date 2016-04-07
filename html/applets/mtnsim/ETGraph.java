import java.util.*;
import java.awt.*;
import edu.iastate.csl.util.Graph;
// awt.event needs to imported for 1.1 style events
//import java.awt.event.*;

public class ETGraph extends Graph implements Observer
/* for 1.1 style events must also implement AdjustmentListener  */
{
    private ReadoutPanel readout;
    private Image icon;
    private Rectangle iconrec;
    public boolean acceptInput;
    private Rectangle xAxisCoods, yAxisCoods;
    private Scrollbar tempsb;
    private SafeScrollbar humidsb;

    private double tempValue = 0.0;
    private double humidValue = 0.0;

    public ETGraph(int w,int h)
    {
        super(w,h);
        acceptInput = true;

        tempValue = 25.0;
        humidValue = 7.0;

        xAxisCoods = getxAxisCoods ();
        yAxisCoods = getyAxisCoods ();
    }

    public ETGraph(int w,int h, String s, Graphics g)
    {
        super(w,h,s,g);
        acceptInput = true;

        tempValue = 25.0;
        humidValue = 7.0;

        xAxisCoods = getxAxisCoods ();
        yAxisCoods = getyAxisCoods ();
    }

    public void clear()
    {
        super.clear();
        plotSaturation();
        drawIcon();
        if (MtnSim.mode.equalsIgnoreCase("record"))
          acceptInput = true;
    }

    public static double dewPointOf(double vaporPress, double airPress)
    {
        // returns temp in C for dewPoint
        /*  double B = 5.42 * Math.pow(10, 3);
        double A = 2.53 * Math.pow(10, 3);
        double epsilon = 0.622;
        double p = airPress;
        double w = (epsilon * vaporPress)/(p);

        return (B/Math.log(A*epsilon/w*p) - 273.0);*/       
        
        // another formula:
        return (2354.0/(9.4041-Math.log(vaporPress)/Math.log(10))-273.0);
    }

    public static double saturationOf(double temp)
    {
        // t is in Celsius
        // returns pressure in mB on the saturation line for given temp
        return (6.112 * Math.exp((17.67*temp)/(temp + 243.5)));

        // another formula
        //(Math.pow(10.0,
        //        - 7.90298 * (373.16/(tempValue +273.0) - 1)
        //        + 5.02808 * (Math.log(373.16/(tempValue + 273))/Math.log(10))
        //        - 1.3816 * Math.pow(10.0, -7) * (Math.pow(10.0, 11.344 * (1 - (tempValue + 273.0)/373.16)) - 1)
        //        + 8.1328 * Math.pow(10.0, -3) * (Math.pow(10.0, -3.49149 * (373.16/(tempValue + 273) - 1)) - 1)
        //        + Math.log(1013.246)/Math.log(10)));
        // yet another formula
        // Math.pow(10.0,-2937.4/(tempValue+273.0)-4.9283*Math.log(tempValue+273.0)/Math.log(10) + 23.5471);
    }

    public void drawIcon()
    {
        Graphics g = getGraphics();
        g.drawImage(icon,iconrec.x,iconrec.y,this);

        if (MtnSim.mode.equalsIgnoreCase("record"))
          {
          int x = iconrec.x + iconrec.width/2;
          int y = iconrec.y + iconrec.height/2;

          /* this is for markers on the axis
          g.setColor (Color.blue);
          g.fillRect (x-1, xAxisCoods.y-1,6,6);
          g.setColor (Color.red);
          g.fillRect (yAxisCoods.x-1,y-1,6,6); */

          }
    }

    public double getHumidity()
    {
        return humidValue;
    }

    public Rectangle getIconRec ()
    {
        return iconrec;
    }

    public double getDewPoint()
    {
        return (dewPointOf(humidValue,1000));
    }

    public double getTemp()
    {
        return tempValue;
    }

    public boolean handleEvent(Event e)
    {
        if (e.target instanceof Scrollbar)
        {
            if ((e.target == tempsb) && (e.id > 600) && (e.id < 606))
            {
                tempValue = (tempsb.getValue()/ReadoutPanel.Md)-ReadoutPanel.tempOffset;
                moveMarker("temp");
                return true;
            }
            else if ((e.target == humidsb) && (e.id > 600) && (e.id < 606))
            {//e.id > 600 and e.id <=605 are scroll events
                humidValue = (((Integer)(e.arg)).doubleValue())/ReadoutPanel.Md;//humidsb.getValue()/ReadoutPanel.Md;
                moveMarker("humid");
                return true;

            }
        }
		return super.handleEvent(e);
	}

    private void moveMarker(String scrolled)
    {
        //System.out.println("hello");
        if (!acceptInput) return;

        Point last = new Point(iconrec.x,iconrec.y);

        int x = xAxis.getLoc(tempValue);
        int y = yAxis.getLoc(humidValue);

        Rectangle r = imageBounds();

        double h = saturationOf(tempValue);

        if (humidValue < h) {
            if (scrolled.equals("temp"))
            {
                humidsb.max = ((int)(h * ReadoutPanel.Md+0.5));
            }

            // move the icon marker
            iconrec.move(x-iconrec.width/2,y-iconrec.height/2);

            Graphics g = getGraphics();
            g.drawImage(theImage,r.x,r.y,r.width,r.height,this);

            drawIcon();

            readout.setTemp(tempValue);
            readout.setHumidity(humidValue);

            readout.setTd(getDewPoint());

            return;
        }
        else  // humidValue >= h
        {
            if (scrolled.equals("temp"))
            {
                humidsb.setValue((int)(h * ReadoutPanel.Md + 0.5));
                humidsb.max = ((int)(h * ReadoutPanel.Md+0.5));


                // find closest temp>tempValue such that h <= humidValue
                //               (note the formula can't be inverted)
                // set humidsb to this h and set tempsb to this temp
                // problem is can't set tempsb since temp is currently
                // scrolling.  Could subclass like did for humid but
                // lots o' processing for each movement of humidsb...
            }
            else // scrolled.equals("humid")
            {

            }

            // reset values
            humidValue = h;
            readout.setHumidity(h);
            readout.setTemp(tempValue);
            readout.setTd(getDewPoint());

            // move icon marker to saturation line
            y = yAxis.getLoc(h);
            iconrec.move(x-iconrec.width/2, y-iconrec.height/2);

            Graphics g = getGraphics();
            g.drawImage(theImage,r.x,r.y,r.width,r.height,this);
            drawIcon();

            g.setColor (Color.gray);
            g.drawRect (x-iconrec.width/2-2,y-iconrec.height/2-2,iconrec.width+4,iconrec.height+4);

        }

    }

    public void paint(Graphics g)
    {
      if (acceptInput) {
        if (theImage == null) {
            super.paint(g);
            int w = icon.getWidth(MtnSim.me);
            int h = icon.getWidth(MtnSim.me);
            iconrec = new Rectangle(xAxis.getLoc(tempValue)-w/2,yAxis.getLoc(humidValue)-h/2,w,h);
            plotSaturation();
        }
        super.paint(g);
        drawIcon();
        readout.setTemp(getTemp());
        readout.tempsb.setValue((int)((getTemp()+ReadoutPanel.tempOffset)*ReadoutPanel.Md+0.5));
        readout.setHumidity(getHumidity());
        readout.humidsb.setValue((int)(humidValue * ReadoutPanel.Md +0.5));
        readout.setTd(getDewPoint());

        readout.setAltitude(0);
        readout.setCba(0);
        readout.setSlope(0);

      }
      else super.paint(g);
    }

    private void plotSaturation()
    {
        setPlotMode(Graph.LINE,Color.black);
        for (double t=xAxis.min; t<= xAxis.max; t++) {
            double h = Math.pow(10.0,-2937.4/(t+273.0)-4.9283*Math.log(t+273.0)/Math.log(10) + 23.5471);
            // Math.pow(10.0,9.4041 - 2354.71/(t+273.0));
            plotBuffer(t,h);
        }
        drawMarker(theImage.getGraphics(),last.x,last.y);
    }

    public void setAcceptInput (boolean value)
    {
        acceptInput = value;
    }

    public void setReadout(ReadoutPanel p)
    {
        readout=p;
        tempsb = readout.tempsb;
        humidsb = readout.humidsb;
    }

    public void setIcon(Image anIcon)
    {
        icon = anIcon;
    }

    public void setTempHumid(double temp, double humid)
    {
        // Simulate movement of temp scrollbar
        tempsb.setValue((int)((temp+ReadoutPanel.tempOffset)*ReadoutPanel.Md+0.5));
        tempValue = temp;
        moveMarker("temp");

        // Simulate movement of humid scrollbar
        humidsb.setValue((int)(humid * ReadoutPanel.Md +0.5));
        humidValue = humid;
        moveMarker("humid");

    }

    public void update(Observable ob,Object arg)
    {
        AirflowRec afr = (AirflowRec) arg;
        plot(afr.temp,afr.humidity);
    }

}
