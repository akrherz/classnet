import java.util.*;
import java.awt.*;
import edu.iastate.csl.util.Graph;

public class ATGraph extends Graph implements Observer {
    public ATGraph(int w,int h) { super(w,h); }

    public ATGraph(int w, int h, String s, Graphics g)
    {
        super(w,h,s,g);
    }

    public void update(Observable ob,Object arg)
    {
        AirflowRec afr = (AirflowRec)arg;
        plot(afr.temp,afr.altitude);
    }
}
