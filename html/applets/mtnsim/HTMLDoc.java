import java.util.*;
import java.applet.Applet;
import netscape.javascript.JSObject;

public class HTMLDoc extends Object {
    private StringBuffer buf;
    private JSObject browser;

    public final static int ORDERED=0;
    public final static int UNORDERED=1;

    public HTMLDoc(Applet applet,String windowName,String title,String bodyOption)
    {
        browser = JSObject.getWindow(applet);
        browser.eval("myWindow = window.open('','"+windowName+"')");
        browser.eval("myWindow.document.open('text/html')");
        buf = new StringBuffer(1000);
        buf.append("<HTML><HEAD><TITLE>"+title+"</TITLE></HEAD><BODY "+bodyOption+">");
    }

    public void close()
    {
        buf.append("</BODY></HTML>");
        String s = buf.toString();
        browser.eval("myWindow.document.write('"+s+"')");
        browser.eval("myWindow.document.close()");
    }

    public void bold(String s) { buf.append("<B>").append(s).append("</B>"); }
    public void italics(String s) { buf.append("<I>").append(s).append("</I>"); }
    public void header(String s,int i)
    {
         String hdr = "H"+i;
         buf.append("<"+hdr+">").append(s).append("</"+hdr+">");
    }
    public void center(boolean on) { buf.append(on?"<CENTER>":"</CENTER>"); }
    public void hr() { buf.append("<HR>"); }
    public void image(String src,String name)
    {
        buf.append("<IMG SRC=\"").append(src).append("\"");
        buf.append(" ALT=\"").append(name).append("\">");
    }

    public void url(String prompt,String url)
    {
         buf.append("<A HREF=\"").append(url).append("\">");
         buf.append(prompt).append("</A>");
    }

    public void url(String prompt,String url,String window)
    {
         buf.append("<A HREF=\"").append(url).append("\"");
         buf.append(" TARGET=\"").append(window).append("\">");
         buf.append(prompt).append("</A>");
    }

    public void table(String caption,String headings[],String cells[],boolean border)
    {
        int nPerRow = headings.length;
        if (border)
            buf.append("<TABLE BORDER>");
        else
            buf.append("<TABLE>");
        buf.append("<CAPTION>"+caption+"</CAPTION>");
        buf.append("<TR ALIGN=RIGHT>");
        for (int i = 0; i < nPerRow;i++)
            {
            //System.out.println ("Headings["+i+"] = " + headings[i]);
            buf.append("<TH>").append(headings[i]).append("</TH>");
            }
        buf.append("</TR>");
        int cnt = 0;
        for (int i = 0; i < cells.length; i++) {
            if (cnt == 0) buf.append("<TR ALIGN=RIGHT>");
            buf.append("<TD>").append(cells[i]).append("</TD>");
            if (++cnt == nPerRow) {
                buf.append("</TR>");
                cnt = 0;
            }
        }
        buf.append("</TABLE>");
    }

    public void list(int type,String items[])
    {
        String eol;
        switch(type) {
        case ORDERED:
            buf.append("<OL>");
            eol = "</OL>";
            break;
        case UNORDERED:
            buf.append("<UL>");
            eol = "</UL>";
            break;
        default:
            eol = "";
        }
        for (int i = 0; i < items.length; i++)
            buf.append("<LI>").append(items[i]).append("");
        buf.append(eol);
    }
}