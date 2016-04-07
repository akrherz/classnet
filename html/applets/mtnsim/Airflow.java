import java.awt.*;
// awt.event needs to imported for 1.1 style events
//import java.awt.event.*;
import java.util.*;
import edu.iastate.csl.util.Portrait;

public class Airflow extends Observable implements Runnable {
    private double maxAltitude = 10.0; // km
    private AirflowRec afr;
    private double factor = 10.0;
    private int startHeight;
    private Portrait window;
    private int imageW;
    private int imageH;
    private Image icon;
    private int iconW,iconH;
    private Image clouds[];
    private Thread theThread;
    private Point cpt = new Point(0,0);
    private int theDelay = 5;
    private Vector path;
    private int ipath = 0;
    private Image buffer;
    private boolean paused;
    private boolean stopped;
    private double lastH = 0;
    private static int inc = 2; // pixels per jump
    public static int STOP = 0; // stop event number

    public Airflow(Portrait c)
    {
        window = c;
    }

    private void animateClouds()
    {
        Graphics bg = buffer.getGraphics();
        Graphics g = window.getGraphics();
        double h = (5.0*afr.altitude);
        if (afr.cloudBase == 0) {
            afr.cloudBase = afr.altitude;
            if(afr.temp == 0 || (9-h) >= 0){
            ((MtnSim)MtnSim.me).thunder();
            }
        }
        // only plot every 200 meters
        if (Math.abs(lastH - h) >= 1) {

            for (int i = 0; i < 9-((int)h); i++) {
                int h1=clouds[i].getHeight(window);
                bg.drawImage(clouds[i],cpt.x-20,cpt.y-h1/2,window);
                sleep(20);
                g.drawImage(buffer,2,2,window);
            }
            lastH = h;
        }
    }

    public void drawIcon(Graphics g)
    {
        g.drawImage(icon,cpt.x-iconW/2,cpt.y-iconH/2,window);
    }

    public void drawIcon()
    {
        window.getGraphics().drawImage(icon,50,50,window);
    }

    public String getCloudBase() { return afr.getCloudBase(); }

    public void pause()
    {
        paused = !paused;
        if (paused)
            theThread.suspend();
        else
            theThread.resume();
    }

    public void run()
    {
        int dx,dy,px,py,p,cb;
        Point pt;

        Graphics g = window.getGraphics();
        Graphics bg = buffer.getGraphics();
        Enumeration ep = path.elements();
        pt = (Point)ep.nextElement();
        startHeight = pt.y;
        stopped = false;
        while (ep.hasMoreElements()) {
            cpt.move(pt.x,pt.y);
            pt = (Point)ep.nextElement();
            int xdelta = pt.x - cpt.x;
            int ydelta = pt.y - cpt.y;
            dx = (xdelta > 0)? inc:(xdelta < 0)? -inc:0;
            dy = (ydelta > 0)? inc:(ydelta < 0)? -inc:0;
            px = Math.abs(xdelta/inc);
            py = Math.abs(ydelta/inc);
            if (py > px) {
                p = py/2;
                for (int i = 0; i < py; i++) {
                    // draw current image and then clear buffer
                    p -= px;
                    if (p < 0) {
                        cpt.translate(dx,dy); p += py;
                    } else
                        cpt.translate(0,dy);
                    g.drawImage(buffer,2,2,window);
                    drawIcon(g);
                    update();
                    sleep(theDelay);
                    if (stopped) return;
    	        }
            } else {
                p = px/2;
                for (int i = 0; i < px; i++) {
                    // draw current image and then clear buffer
                    p -= py;
                    if (p < 0) {
                        cpt.translate(dx,dy); p += px;
                    } else
                        cpt.translate(dx,0);
                    g.drawImage(buffer,2,2,window);
                    drawIcon(g);
                    update();
                    sleep(theDelay);
                    if (stopped) return;
     			}
            }
        }
        MtnSim.me.postEvent(new Event(this,STOP,afr));
    }

    public void setDelay(int delay)
    {
        if (delay > 0)
            theDelay = delay;
        else theDelay = 0;
    }

    public void setIcon(Image img,Image cld[])
    {
        icon = img;
        iconW = icon.getWidth(MtnSim.me);
        iconH = icon.getHeight(MtnSim.me);
        clouds = cld;
    }

    public void setPath(Vector p)
    {
        if (p.size() > 1)
            path = p;
    }

    public void setStartConditions(double maxA,double startT,double startH,double startP,double startA, double startTd)
    {
        maxAltitude = maxA;
        afr = new AirflowRec(startT,startH,startP,startA, startTd);
    }

    private void sleep(int delay)
    {
       try {
                theThread.sleep(delay); }
       catch (InterruptedException e) {}
    }

    public void start()
    {
        Rectangle r = window.imageBounds();
        buffer = window.createImage(r.width,r.height);
        Graphics bg = buffer.getGraphics();
        bg.drawImage(window.getImage(),0,0,r.width,r.height,window);
        theThread = new Thread(MtnSim.myGroup,this,"Airflow");
        theThread.start();
        paused = false;
    }

    public void stop()
    {
        stopped = true;
        theThread = null;
    }

    public void update()
    {
        Rectangle r = window.bounds();
        double oldA = afr.altitude;
        double oldT = afr.temp;
        double oldP = afr.pressure;
        double oldTd = afr.td;

        afr.altitude = afr.altStart + ((double)(startHeight - cpt.y)/r.height)*maxAltitude;

        if (afr.altitude < 0)
            afr.altitude = 0;

        afr.pressure = afr.pressStart - 125*( afr.altitude - afr.altStart);
        afr.humidity = afr.humidity * afr.pressure/oldP;
        afr.td = ETGraph.dewPointOf(afr.humidity,afr.pressure);
            // 2354.0/(9.4041-Math.log(afr.humidity)/Math.log(10))-273.0;
        afr.temp = oldT - factor*(afr.altitude-oldA);
        double h = ETGraph.saturationOf(afr.temp);
        // changed:  9.4041 - 2354.0/((afr.temp)+273.0));
        // to:       -2937.4/Temp -4.9283logbase10(Temp) + 23.5471
        // Math.pow(10.0,-2937.4/(afr.temp+273.0)-4.9283*(Math.log(afr.temp+273.0)/Math.log(10)) + 23.5471);

        if (afr.altitude != oldA) {
            //afr.taSlope = (afr.altitude - oldA)/(afr.temp - oldT);
            afr.taSlope = (afr.temp - oldT)/(afr.altitude - oldA);
        }
        if (afr.humidity > h) {
            animateClouds();
            afr.humidity = h;
            factor = 6.0;
        }
        if ( afr.temp > oldT){

            factor = 10.0;
        }
        setChanged();
        notifyObservers(afr);
    }

    public void updateConditions(double t,double h, double td)
    {
        afr.temp = t;
        afr.humidity = h;
        afr.td= ETGraph.dewPointOf(afr.humidity,afr.pressure);
            // 2354.0/(9.4041-Math.log(afr.humidity)/Math.log(10))-273.0;
       // afr.es=Math.pow(10.0,9.4041 - 2354.0/((afr.temp)+273.0));
        setChanged();
        notifyObservers(afr);
    }

}
