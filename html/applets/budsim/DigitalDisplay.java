import java.awt.*;

public class DigitalDisplay extends Panel {
    private Color numColor;
    private String strVal;
    private int textX;
    private int textH;
    private int minW;
    private int minH;
    private int B;  // Border Width
    private int M = 2;  // Margin Width

    public DigitalDisplay(Color aColor, int borderWidth)
    {
        B = borderWidth;
        Graphics g = BudgetSim.me.getGraphics();
        Font tmpFont = g.getFont();
        Font f = new Font("Helvetica",Font.PLAIN,14);
        g.setFont(f);
        FontMetrics fm = g.getFontMetrics();
        strVal = "00.00";
        minW = fm.stringWidth(strVal)+ 2*B + 2*M ;
        minH = fm.getHeight()+2*M;
        textX = M+B;
	    textH = fm.getLeading() + fm.getAscent() + M + B;
        numColor = aColor;
		setFont(f);

    }

    public void paint(Graphics g)
    {
        paint_border(g);

        fill_border(g);

	    g.setColor(numColor);
	    g.drawString(strVal,textX,textH);
	}

    private void paint_border(Graphics g)
    {
        // ******  This makes a border of width 2 ********* //
        Rectangle bnd = bounds();

        for (int i = 0; i<B; i++)
        {
            g.setColor(Color.black);

            //horizontal black (top)
            g.drawLine(0,i,bnd.width-1-i, i);
            //vertical black (Left side)
            g.drawLine(i,0,i,bnd.height-1-i);

            g.setColor(Color.white);

            //horizontal white (bottom)
            g.drawLine(i+1,bnd.height-1-i,bnd.width-1-i,bnd.height-1-i);
            //vertical white (right side)
            g.drawLine(bnd.width-1-i,i,bnd.width-1-i,bnd.height-1-i);
        }

    }

    private void fill_border(Graphics g)
    {
        // ******* This assumes the border is width 2 ******* //
        Rectangle bnd = bounds();
        g.setColor(Color.black);
        g.fillRect(B,B,bnd.width-2*B,bnd.height-2*B);
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
    { return new Dimension(minW,minH);
    }

    public Dimension preferredSize()
    { return minimumSize();
    }

    public void setValue(double nval)
    {
        Graphics g = getGraphics();
        strVal = String.valueOf(nval);

        fill_border(g);

	    g.setColor(numColor);
        FontMetrics fm = g.getFontMetrics();
        textX = minW - fm.stringWidth(strVal) - 2*M - 2*B;
	    g.drawString(strVal,textX,textH);
    }
}
