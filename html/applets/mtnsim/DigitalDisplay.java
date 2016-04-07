import java.awt.*;

public class DigitalDisplay extends Panel {
    private Color numColor;
    private String strVal;
    private int textX;
    private int textH;
    private int minW;
    private int minH;

    public DigitalDisplay(Color aColor)
    {
        //Graphics g = MtnSim.me.getGraphics();
        //Font tmpFont = g.getFont();
        //Font f = new Font("Courier",Font.PLAIN,12);
        //g.setFont(f);

        Font f = new Font("Courier",Font.PLAIN,12);
		setFont(f);
        FontMetrics fm = getFontMetrics(f);
        strVal = "000.00";
        minW = fm.stringWidth(strVal)+8;
        minH = fm.getHeight()+4;
        textX = 4;
	    textH = fm.getLeading() + fm.getAscent()+2;

        numColor = aColor;
		//setFont(f);
    }

    public void paint(Graphics g)
    {
        Rectangle bnd = bounds();

	    g.setColor(Color.white);
        // right side
	    g.drawLine(bnd.width-1,0,bnd.width-1, bnd.height-1);
	    // bottom
	    g.drawLine(1,bnd.height-1,bnd.width-1, bnd.height-1);

	    g.setColor(Color.gray);
        // left side
	    g.drawLine(0,0,0,bnd.height-1);
	    // top
	    g.drawLine(0,0,bnd.width-1,0);

	    g.setColor(Color.black);
	    g.fillRect(1,1,bnd.width-2, bnd.height-2);

	    g.setColor(numColor);
	    g.drawString(strVal,textX,textH);
	}

    public void resize(int w,int h)
    {
        w = Math.max(w,minW);
        h = Math.max(h,minH);
        super.resize(w,h);
    }

    public void reshape(int x,int y,int w,int h)
    {
        w = Math.max(w,minW);
        h = Math.max(h,minH);
        super.reshape(x,y,w,h);
    }

    public void resize(Dimension d)
    {
        resize(d.width,d.height);
    }

    public Dimension minimumSize()
    {
        return new Dimension(minW,minH);
    }

    public Dimension preferredSize()
    {
        return minimumSize();
    }

    private int min (int a, int b)
    {
        if (a < b)
          return a;
        return b;
    }

    public void setValue(double nval)
    {
        Graphics g = getGraphics();
        strVal = String.valueOf(Math.round(nval*10.0)/10.0);
        if (strVal.indexOf(".") == -1)
        {
            strVal += ".0";
        }

        else
            strVal = strVal.substring (0,strVal.indexOf (".") + 2);

        FontMetrics fm = g.getFontMetrics();

        Rectangle bnd = bounds();
        textX = bnd.width - fm.stringWidth(strVal) - 6;

	    g.setColor(Color.black);
	    g.fillRect(1,1,bnd.width-2, bnd.height-2);

	    g.setColor(numColor);
	    g.drawString(strVal,textX,textH);
    }

    public void setValue(String sval)
    {
        strVal = sval;

        Graphics g = getGraphics();

        FontMetrics fm = g.getFontMetrics();
        Rectangle bnd = bounds();
        textX = bnd.width - fm.stringWidth(strVal) - 6;

	    g.setColor(Color.black);
	    g.fillRect(1,1,bnd.width-2, bnd.height-2);

	    g.setColor(numColor);
	    g.drawString(strVal,textX,textH);

    }

}
