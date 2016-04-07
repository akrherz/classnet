import java.util.*;
import java.awt.*;
import edu.iastate.csl.util.Graph;

public class RateGraph extends Graph implements Observer {
    public RateGraph(int w,int h) { super(w,h); }

    public void paint (Graphics g) {
        if(theImage == null) {
            super.paint(g);
            plotDrain();
            }

        super.paint(g);
    }

    public void update(Observable ob,Object arg)
    {
        flowRec fr = (flowRec)arg;
        plot(fr.time,fr.rate);
    }

    public void clear()
    {
        super.clear();
        plotDrain();
    }

    private void plotDrain()
    {
        setPlotMode(Graph.LINE, Color.blue);
        for(double t=xAxis.min; t<= xAxis.max; t++)  {
            double r = 1.0;
            plotBuffer(t, r);
        }
    }

}
