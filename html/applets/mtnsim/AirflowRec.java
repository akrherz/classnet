import java.awt.*;

public class AirflowRec extends Object {
    double tempStart;
    double altStart;
    double pressStart;
    double humStart;
    double tdStart;
    //double esStart;
    double cloudBase;
    double temp;
    double humidity;
    double altitude;
    double pressure;
    double td;
    double taSlope;
    //double es;

    public static final int LEFT=0;
    public static final int CENTER=1;
    public static final int RIGHT=2;
    public static final int FWIDTH=30;

    public AirflowRec(double startT,double startH,double startP,double startA, double startTd)
    {
        temp = tempStart = startT;
        humidity = humStart = startH;
        pressure = pressStart = startP;
        altitude = altStart = startA;
        td=tdStart=startTd;
        taSlope = (double)0.0;
        //es=esStart=startEs;
    }

    public static String heading(FontMetrics fm)
    {
        return justify("Init. Temp(C)",fm,FWIDTH,CENTER)+
               justify("Init. Vapor Pressure(mb)",fm,FWIDTH,CENTER)+
               justify("Init. Td(C)",fm,FWIDTH,CENTER)+
               //justify("Init. Saturaed Vapor(mb)",fm,FWIDTH,CENTER)+
               justify("Cloud Base(km)",fm,FWIDTH,CENTER)+
               justify("Final Temp(C)",fm,FWIDTH,CENTER)+
               justify("Final Td(C)",fm,FWIDTH,CENTER)+
               justify("Final Vapor Pressure(mb)",fm,FWIDTH,CENTER)+"\n";
    }

    public static String[] heading()
    {
        String h[] = {"Init. Temp(C)","Init. Vapor Pressure(mb)","Init. Td(C)", "Cloud Base(km)","Final Temp(C)","Final Td(C)","Final Vapor Pressure(mb)"};
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
        String cbstr;
        if (cloudBase == 0)
            cbstr = justify("Clear",fm,FWIDTH,CENTER);
        else
            cbstr = cjust(cloudBase,fm);

        return cjust(tempStart,fm)+
               cjust(humStart,fm)+
               cjust(tdStart,fm)+
               //cjust(esStart,fm)+
               cbstr+
               cjust(temp,fm)+
               cjust(td,fm)+
               cjust(humidity,fm)+"\n";
    }

    public String[] format()
    {
        String s[] =
            {   truncStr(tempStart),
                truncStr(humStart),
                truncStr(tdStart),
                //truncStr(esStart),
                cloudBase == 0?"Clear":truncStr(cloudBase),
                truncStr(temp),
                truncStr(td),
                truncStr(humidity)
            };
        return s;
    }

    public String getCloudBase()
    {
        String cbstr;
        if (cloudBase == 0)
            cbstr = ("Clear");
        else
            cbstr = truncStr(cloudBase);

        return cbstr;
        }

    public double getCloudBaseDouble()
    {
        return cloudBase;
    }

    public double getSlope()
    {
        return taSlope;
    }

    private int min (int a, int b)
    {
        if (a < b)
          return a;
        return b;
    }

    private String truncStr(double v)
    {
        String strVal = new String (String.valueOf(Math.ceil(100*v)/100));
        strVal = strVal.substring (0,strVal.indexOf (".") +
                                   min (3, strVal.length() - strVal.indexOf("."))
                                  );
        return strVal;
    }

    private String cjust(double v,FontMetrics fm)
    {
        return(justify(truncStr(v),fm,FWIDTH,CENTER));
    }

}
