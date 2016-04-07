# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub print_main_menu {
    @cls_files = CLASS::list();

    CN_UTILS::print_cn_header("Main Menu");

    print <<"START_FORM";
<FORM METHOD="POST" ACTION="$GLOBALS::SECURE_SCRIPT_ROOT/get_login">
<INPUT TYPE=hidden NAME="cn_option" VALUE="Get Login">
<TABLE WIDTH=60%>
<TR ALIGN="CENTER">
<TD ALIGN="LEFT"><CENTER><B>Login Directions</B></CENTER>
Step 1. Click on a class name<BR>
Step 2. Click on Login<BR>
<P>
<B>First-time Options</B><BR>
<B>Students:</B> <A 
HREF="$GLOBALS::SECURE_SCRIPT_ROOT/get_stud_reg_form">Join a 
ClassNet class</A><BR>
<B>Instructors:</B> <A 
HREF="$GLOBALS::SECURE_SCRIPT_ROOT/get_class_reg_form">Create a 
ClassNet class</A>
</TD>
<TD>
<B>Classes</B><BR>
<SELECT SIZE=8  NAME="Class Name">
START_FORM
   
    foreach $cls_name (@cls_files) {
       print qq|<OPTION> $cls_name\n|;
    }

    print <<"END_FORM"
</SELECT>
<P>
<B><INPUT NAME="name" TYPE="submit" VALUE="Login"></B>
</TD>
</TR>
</TABLE>
<HR SIZE="4">
<CENTER>
$GLOBALS::RED_BALL<A HREF="$GLOBALS::SERVER_ROOT/help/index.html">Help</A> 
$GLOBALS::RED_BALL<A HREF="$GLOBALS::MAIL">Questions?</A>
$GLOBALS::RED_BALL<A HREF="$GLOBALS::SERVER_ROOT/credits.html">Credits</A>
</CENTER>
</FORM>
</BODY>
</HTML>
END_FORM
}

1;
