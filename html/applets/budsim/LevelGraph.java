import java.util.*;
import java.awt.*;
import edu.iastate.csl.util.Graph;

public class LevelGraph extends Graph implements Observer {
    public LevelGraph(int w,int h, Graphics g)
    {
        super(w,h,"000",g);
    }

    public void update(Observable ob,Object arg)
    {
        flowRec fr = (flowRec)arg;
        plot(fr.time,fr.rate);
    }
}
