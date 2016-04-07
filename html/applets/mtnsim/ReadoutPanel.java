import java.awt.*;
import java.util.*;
// awt.event needs to imported for 1.1 style events
//import java.awt.event.*;

public class ReadoutPanel extends Panel implements Observer {
    private DigitalDisplay temp;
    private DigitalDisplay humidity;
    private DigitalDisplay altitude;
    private DigitalDisplay td;
    private DigitalDisplay slope;
    private DigitalDisplay cba;

    private Label lab1;
    private Label lab2;
    private Label lab3;
    private Label lab4;
    private Label lab5;
    private Label lab6;

    private ETGraph etgraph;

    public Scrollbar tempsb;
    private int tempSlider = (MtnSim.tempMax - MtnSim.tempMin) / 10;
    private int tempInit = (int)(((MtnSim.tempMax) - (MtnSim.tempMin))/ 2.0 + MtnSim.tempMin);
    private int tempMax = MtnSim.tempMax + tempSlider;
    private int tempMin = MtnSim.tempMin;

    public SafeScrollbar humidsb;
    private int humidSlider = (MtnSim.vaporMax - MtnSim.vaporMin) / 10;
    private int humidInit = (int)(((MtnSim.vaporMax) - (MtnSim.vaporMin))/ 2.0 + MtnSim.vaporMin);
    private int humidMax = MtnSim.vaporMax + humidSlider;
    private int humidMin = MtnSim.vaporMin;

    public static int M = 10;  // the multiplier for humidsb and tempsb -- this is used to
                        // simulate a scrollbar with more precision
    public static double Md = 10.0;
    public static int tempOffset = (MtnSim.tempMin < 0)? -MtnSim.tempMin : 0;
                        // tempOffset is a workaround because the temp scrollbar behaves
                        // unexpectedly when the slider is dragged into the negative number region
                        // Note that the offset must be subtracted after dividing by M
                        // (or added before multiplying by M)


    public ReadoutPanel()
    {
	    int REM = GridBagConstraints.REMAINDER;
	    int REL = GridBagConstraints.RELATIVE;

        setBackground (Color.lightGray);

	    GridBagLayout gbl = new GridBagLayout();
	    setLayout(gbl);

        temp = new DigitalDisplay(Color.green);

        int slidersize = (MtnSim.tempMax - MtnSim.tempMin) / 10;

        tempsb = new Scrollbar(Scrollbar.HORIZONTAL, tempInit*M, tempSlider*M, (tempMin+tempOffset)*M, (tempMax+tempOffset)*M);
        tempsb.setLineIncrement(1);
        tempsb.setPageIncrement(10);
        tempsb.setBackground(new Color(160,160,160));

        humidity = new DigitalDisplay(Color.green);
        slidersize = (MtnSim.vaporMax - MtnSim.vaporMin) / 10;
        humidsb = new SafeScrollbar(Scrollbar.HORIZONTAL, humidInit*M, humidSlider*M, humidMin*M, humidMax*M);
        humidsb.setLineIncrement(1);
        humidsb.setPageIncrement(10);
        humidsb.setBackground(new Color(160,160,160));
        humidsb.resize(200,100);

        altitude = new DigitalDisplay(Color.green);
        td = new DigitalDisplay(Color.green);
        slope = new DigitalDisplay(Color.green);
        cba = new DigitalDisplay(Color.green);

        lab1 = new Label("Parcel Temperature(C)", Label.LEFT);
        addReadout(lab1,gbl,1,0,0,0);
        addReadout(temp,gbl,1,1,0,0);
        addReadout(tempsb,gbl,1,2,0,20);

        lab2 = new Label("Water Vapor Pressure(mb)",Label.LEFT);
        addReadout(lab2,gbl,1,0,1,0);
        addReadout(humidity,gbl,1,1,1,0);
        addReadout(humidsb,gbl,1,2,1,20);

        lab3 = new Label("Dew Point(C)",Label.LEFT);
        addReadout(lab3,gbl,1,0,2,0);
        addReadout(td,gbl,1,1,2,0);

        lab4 = new Label("Parcel Altitude(km)",Label.LEFT);
        addReadout(lab4,gbl,1,0,3,0);
        addReadout(altitude,gbl,1,1,3,0);

        lab5 = new Label("Slope (C/km)",Label.LEFT);
        addReadout(lab5,gbl,1,0,4,0);
        addReadout(slope,gbl,1,1,4,0);

        lab6 = new Label("Cloud Base Altitude(km)",Label.LEFT);
        addReadout(lab6,gbl,1,0,5,0);
        addReadout(cba,gbl,1,1,5,0);

    }

    private void addReadout(Component c,GridBagLayout gbl,int gw,int gx,int gy, int ipadx)
    {
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.gridwidth = gw;
        gbc.gridx = gx;
        gbc.gridy = gy;
        gbc.weightx = 0;
        gbc.weighty = 0;
        gbc.ipadx = ipadx;
        gbc.fill = GridBagConstraints.NONE;
        gbc.anchor = GridBagConstraints.WEST;
	    gbc.insets = new Insets(0,5,0,0);
        gbl.setConstraints(c,gbc);
        add(c);
    }

    public boolean handleEvent (Event e)
    {   // this handles the jdk1.0 scrollbar events
        //
        // for jdk1.1 etgraph is registered as a listener and this
        // method is not used
        if (e.target instanceof Scrollbar)
        {
            return (etgraph.handleEvent(e));
        }
        else return super.handleEvent(e);
    }

    private double logBase10(double y)
    {
        return (Math.log(y) / Math.log(10));
    }

    public void setAcceptInput(boolean accInp) {
        if (accInp) {
            tempsb.enable();
            humidsb.enable();
        } else {
            tempsb.disable();
            humidsb.disable();
        }
    }

    public void setAltitude(double a)
    {
        altitude.setValue(a);
    }

    public void setCba(double cbaVal)
    {
        if (cbaVal != 0) {
            cba.setValue(cbaVal);
        } else {
            cba.setValue("Clear");
        }
    }

    public void setETGraph(ETGraph g)
    {
        etgraph = g;
    }

    public synchronized void setHumidity(double h)
    {
        humidity.setValue(h);
    }

    public void setSlope(double slopeVal)
    {
        slope.setValue(slopeVal);
    }

    public void setTd(double td1)
    {
        td.setValue(td1);
    }

    public synchronized void setTemp(double t)
    {
        temp.setValue(t);
    }

    private double trunc(double v)
    {
        return Math.ceil(100*v)/100.0;
    }

    public void update(Observable ob,Object arg)
    {
        AirflowRec afr = (AirflowRec)arg;
        setTemp(afr.temp);
        setHumidity(afr.humidity);
        setAltitude(afr.altitude);
        setTd(afr.td);
        setSlope(afr.taSlope);
        setCba(afr.getCloudBaseDouble());

    }
}
