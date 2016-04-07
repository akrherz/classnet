import java.awt.*;

public class flowRec extends Object {
    double timeStart;
    double rateStart;
    double levelStart;

    double time;
    double rate;
    double level;


    public static final int LEFT=0;
    public static final int CENTER=1;
    public static final int RIGHT=2;
    public static final int FWIDTH=30;

    public flowRec(double startT,double startR,double startL)
    {
        time = timeStart = startT;
        rate = rateStart = startR;
        level = levelStart = startL;

    }

      public static String heading(FontMetrics fm)
      {
          return justify("Time(hour)",fm,FWIDTH,CENTER)+
                 justify("Water Level(l)",fm,FWIDTH,CENTER)+
               justify("Flow Rate (l/hr)",fm,FWIDTH,CENTER)+"\n";

    }

    public static String[] heading()
    {
        String h[] = {"Time(hour)","Water Level(l)","Flow Rate (l/hr)"};
        return h;
    }

    public static String justify(String s,FontMetrics fm,int width,int t)
    {
        int swidth = width*fm.stringWidth(" ");
        boolean addToLeft = true;
        while (fm.stringWidth(s) < swidth) {
            switch(t) {
                case LEFT:
                    s += " ";
                    break;
                case CENTER:
                    s = addToLeft? " " + s: s + " ";
                    addToLeft = !addToLeft;
                    break;
                case RIGHT:
                    s = " " + s;
                default:
                    break;
            }
        }
        return s;
    }

    public String format(FontMetrics fm)
    {


        return cjust(timeStart,fm)+
               cjust(levelStart,fm)+
               cjust(rateStart,fm)+

               cjust(time,fm)+
               cjust(level,fm)+
               cjust(rate,fm)+"\n";
    }

    public String[] format()
    {
        String s[] =
            {   truncStr(timeStart),
                truncStr(levelStart),
                truncStr(rateStart),

                truncStr(time),
                truncStr(level),
                truncStr(rate)
            };
        return s;
    }


    private String truncStr(double v)
    {
        return String.valueOf(Math.ceil(100*v)/100);
    }

    private String cjust(double v,FontMetrics fm)
    {
        return(justify(truncStr(v),fm,FWIDTH,CENTER));
    }


}