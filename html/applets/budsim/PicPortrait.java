import java.awt.*;
import java.applet.Applet;
import edu.iastate.csl.util.Axis;

public class PicPortrait extends Canvas {
    protected Image theImage;
    private int MARGIN = 2;
    Axis scale;
    Image back;
    Image container;
    private boolean new_image = true;


    public PicPortrait(Image background_image,Image container_image,int w,int h)
    {
        back = background_image;
        container = container_image;
        resize(w,h);
        new_image = true;
    }



    private void create_image ()
      {
        Image faucet1 = BudgetSim.me.getFaucetImage ();
        Rectangle r = imageBounds ();


        new_image = false;
        int image_x = r.x;
        int image_y = r.y ;
        int image_width = r.width;
        int image_height = r.height;

        int can_x = r.x + r.width/5;
        int can_y = image_y + 25; // r.y + 32
        int can_width = r.width/2 + 17;
        int can_height = r.height-45;

        theImage = BudgetSim.me.createImage (image_width,image_height);
        Graphics g = theImage.getGraphics ();

        if ( container != null )
          {
          g.drawImage (container,0,0,image_width,image_height,this);
          //waitForImage (this,container);
          }
        else
          {
          if (back != null)
            {
            g.drawImage (back,0,0,r.width,r.height,this);
            //waitForImage (this,back);
            }
          else
            {
            g.setColor (Color.white);
            g.fillRect (2,2,r.width-1,r.height-1);
            }
          g.setColor (Color.black);
          g.drawRoundRect(can_x,can_y,can_width,can_height, (can_width*5)/6 + 20, can_height/8);
          }


         //Initialize Axis
        scale = new Axis(Axis.VERTICAL, r.x + r.width/8, can_y, 10, can_height);
        scale.setBounds(0,100,10.0, 0.0);
        scale.paint(g);
      }

    public void update (Graphics g)
    {
          this.paint (g);
    }

    public void paint(Graphics g)
    {
        paint_border(g);

        this.create_image ();
        my_paint(g);
	}

    private void paint_border(Graphics g)
    {
        Rectangle bnd = bounds();
        g.setColor(Color.black);
        //horizontal black (top)
        g.drawLine(0,0,bnd.width-1, 0);
        g.drawLine(0,1,bnd.width-2, 1);
        //vertical black (Left side)
        g.drawLine(0,0,0,bnd.height-1);
        g.drawLine(1,0,1,bnd.height-2);

        g.setColor(Color.white);
        //horizontal white (bottom)
        g.drawLine(1,bnd.height-1,bnd.width-1,bnd.height-1);
        g.drawLine(2,bnd.height-2,bnd.width-2,bnd.height-2);
        //vertical white (right side)
        g.drawLine(bnd.width-1,0,bnd.width-1,bnd.height-1);
        g.drawLine(bnd.width-2,1,bnd.width-2,bnd.height-2);

    }

    public void my_paint (Graphics g)
     {
     Image temp_image ;

     Rectangle r = imageBounds ();

     temp_image = BudgetSim.me.createImage (r.width,r.height);
     Graphics bg = temp_image.getGraphics ();
     bg.drawImage (theImage,0,0,r.width,r.height,this);
     //waitForImage (this, temp_image);
     fill_water_level (bg);
     g.drawImage (temp_image,r.x,r.y,r.width,r.height,this);
     //waitForImage (this,temp_image);
     }

    public void my_paint ()
     {
     this.my_paint (theImage.getGraphics());
     }

    private void fill_water_level (Graphics g)
     {
        Image faucet1 = BudgetSim.me.getFaucetImage ();
        int yValue = BudgetSim.me.getyValue();

        Rectangle r = imageBounds ();

        int image_x = 0;
        int image_y = 0 ;
        int image_width = r.width;
        int image_height = r.height;

        int can_x = image_x + r.width/5;
        int can_y = image_y + 25; // r.y + 32
        int can_width = r.width/2 + 17 ;
        int can_height = r.height-45;

        //g.setColor (new Color (0,200,255));
        g.setColor (Color.blue);
        if ( container == null )
          {
          // Scale yValue to proper height
          // yValue = 100 => can_height
          // yValue = 0 => can_y
          yValue = yValue * can_height / 100;

          g.drawImage(faucet1, can_x-10,can_y-10, this);
          g.drawImage(faucet1, can_x+can_width,can_y+can_height-20, this);
          g.setColor (new Color (0,200,255));
          g.fillRoundRect(can_x,(can_y -yValue)+can_height,can_width,yValue, (can_width*5)/6+20,can_height/8);
          }
        else
          {
          // Scale yValue to proper height
          // yValue = 100 => can_height
          // yValue = 0 => can_y
          int curvature_ht = can_height/8;
          int curvature_width = (can_width*5)/6 + 20;
          int ht = yValue * (can_height)/100 + 16;
          int start_ht = (can_y -yValue -6) + can_height;
          int width_adj =0;

          if (yValue < 7)
             {
             curvature_ht = can_height/8 + 60;
             curvature_width = (can_width*5)/6 + 10;
             width_adj = 20;
             }

          if (yValue != 0)
            {
            yValue = yValue * (can_height) / 100;
            // Patch the Bottom & then fill.
            g.fillRoundRect (can_x + width_adj/2, (can_y -yValue -6) + can_height,
                             can_width - width_adj, ht,
                             curvature_width,curvature_ht);
            }

          }
     }

    // used for recording path
    public boolean mouseDown(Event e,int x,int y)
    {
        //System.out.println(x+","+y);
        return true;
    }

    public void resize(int w,int h)
    {
        super.resize(w,h);
    }

    public void reshape(int x,int y,int w,int h)
    {
        super.reshape(x,y,w,h);
    }

    public void resize(Dimension d)
    {
        resize(d.width,d.height);
    }

    public void setImage(Image img)
    {
        theImage = img;
        repaint();
    }

    public Image getImage() { return theImage; }

    public Rectangle imageBounds()
    {
        return new Rectangle(MARGIN,MARGIN,
                             size().width-2*MARGIN,
                             size().height-2*MARGIN);
    }
        
}
