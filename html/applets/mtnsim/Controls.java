import java.awt.*;
// awt.event needs to imported for 1.1 style events
//import java.awt.event.*;
import java.net.*;

public class Controls extends Panel {

    public static int RUN = 1, RESETSIM = 2, SPEEDBAR = 3;
    public static Button runButton; // this is public for feedback statement
                             // in MtnSim.java
    private Button resetSim;
    private Scrollbar speedbar;
    private int sliderSize = 60;
    private int scrollMinValue = 0;
    private int scrollMaxValue = 250;
    private int scrollInitValue = (scrollMaxValue)/2;

    private Label sbLabel = new Label("Wind Speed",Label.CENTER);

    public Controls()
    {
        BorderLayout bl = new BorderLayout(5,0);
        setLayout(bl);

        URL cb = MtnSim.me.getCodeBase();
        runButton = new Button(" Start Wind ");
        add("West", runButton);
        runButton.enable();

        Panel sbPanel = new Panel();
        sbPanel.setLayout(new BorderLayout());

        sbPanel.add("North", sbLabel);

        speedbar = new Scrollbar(Scrollbar.HORIZONTAL,scrollInitValue,sliderSize,scrollMinValue,scrollMaxValue+sliderSize);
        speedbar.setLineIncrement(25);
        speedbar.setPageIncrement(50);
        speedbar.setBackground(new Color(160,160,160));

        sbPanel.add("Center", speedbar);

        add("Center",sbPanel);

        resetSim = new Button(" New Trial ");
        add("East", resetSim);
        resetSim.disable();

    }

    public boolean action(Event e, Object o)
    {   // this handles the jdk1.0 button events by calling
        // the action method in MtnSim
        // for jdk1.1 mtnsim is registered as a listener and this
        // method is not used
        //System.out.println("in Controls.action");
        if (e.target instanceof Button)
        {
            return (MtnSim.me.action(e, o));
        }
        return true;
    }

/*    public void addResetSimButtonListener(ActionListener l)
    {
        if (!MtnSim.jdk10)
            resetSim.addActionListener(l);
    }

    public void addRunButtonListener(ActionListener l)
    {
        if (!MtnSim.jdk10)
            runButton.addActionListener(l);
    }

    public void addScrollBarListener(AdjustmentListener l)
    {
        if (!MtnSim.jdk10)
            speedbar.addAdjustmentListener(l);
    }
*/
    public void disableControlItem(int cntrlItm)
    {
        if      (cntrlItm == RUN)       runButton.disable();
        else if (cntrlItm == RESETSIM)  resetSim.disable();
        else if (cntrlItm == SPEEDBAR)  {speedbar.disable();
                                         sbLabel.setForeground(Color.gray);}
    }

    public void enableControlItem(int cntrlItm)
    {
        if      (cntrlItm == RUN)        runButton.enable();
        else if (cntrlItm == RESETSIM)   resetSim.enable();
        else if (cntrlItm == SPEEDBAR)   {speedbar.enable();
                                          sbLabel.setForeground(Color.black);}
    }

    public int getSpeed()
    {
        return (speedbar.getValue());
    }

    public int getMaxSpeed()
    {
        return scrollMaxValue;
    }

    public boolean handleEvent (Event e)
    {   // this handles the jdk1.0 scrollbar events
        //
        // for jdk1.1 mtnsim is registered as a listener and this
        // method is not used
        //System.out.println("in Controls.handleEvent()");
        return MtnSim.me.handleEvent(e);
    }

    public boolean isControlItem(int cntrlItm, Object obj)
    {
        if      (cntrlItm == RUN)       return (runButton == obj);
        else if (cntrlItm == RESETSIM)  return (resetSim == obj);
        else if (cntrlItm == SPEEDBAR)  return (speedbar == obj);
        else    return false;
    }

}
