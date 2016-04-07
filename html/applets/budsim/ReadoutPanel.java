import java.awt.*;
import java.util.*;

public class ReadoutPanel extends Panel {
    private DigitalDisplay text;
    private Label label;

    public ReadoutPanel(String str)
    {
	    GridBagLayout gbl = new GridBagLayout();
	    GridBagConstraints gbc = new GridBagConstraints ();
	    gbc.fill = GridBagConstraints.BOTH;

	    setLayout(gbl);

	    gbc.weighty = 1;
        gbc.weightx = 1;
        label = new Label(str);
        addComponent(this,label,gbl,gbc,0,0,1,1);

        gbc.weightx = 1;
        gbc.weighty = 1;
        text = new DigitalDisplay(Color.green,2);
        addComponent(this,text,gbl,gbc,0,1,1,1);
    }

    public ReadoutPanel()
    {
	    GridBagLayout gbl = new GridBagLayout();
	    GridBagConstraints gbc = new GridBagConstraints ();
	    gbc.fill = GridBagConstraints.BOTH;

	    setLayout(gbl);


        gbc.weightx = 1;
        gbc.weighty = 1;
        text = new DigitalDisplay(Color.green,1);
        addComponent(this,text,gbl,gbc,0,0,1,1);
    }

    private void addComponent (Panel p,Component c, GridBagLayout g,
                               GridBagConstraints gc, int row,
                               int column, int width, int height)
       {
       // Set gridx & gridy

       gc.gridx = column;
       gc.gridy = row;

       // Set the gridwidth & gridheight
       gc.gridwidth = width;
       gc.gridheight = height;

       g.setConstraints (c,gc);
       p.add (c);
       }

    public void setValue(double t)
    {
        text.setValue(trunc(t));
    }

    private double trunc(double v)
    {
        return Math.ceil(100*v)/100.0;
    }
}
