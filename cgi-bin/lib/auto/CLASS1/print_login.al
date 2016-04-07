# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub print_login {
    my ($self) = @_;
    CN_UTILS::print_cn_header("Identification");
    print <<"END_FORM";
<FORM METHOD="POST" ACTION="$GLOBALS::SECURE_SCRIPT_ROOT/get_login">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="cn_option" VALUE="Get Menu">
<CENTER><B>$self->{'Name'}</B></CENTER><BR>
<table align="center">
<tr>
<td>
<pre>
<B>Email:    </B><INPUT NAME=Email><BR>
<B>Password: </B><INPUT TYPE=Password NAME=Password>
</pre>
</td>
</tr>
</table>
<CENTER><B><INPUT TYPE=submit Value=Login> <INPUT TYPE=reset></B>
<P><a 
href="$GLOBALS::SERVER_ROOT/help/get_login.html#password">Forget 
your Password?</a>
</CENTER>
</FORM>
$GLOBALS::HR
<CENTER><img SRC="$GLOBALS::SERVER_IMAGES/warning.gif" ALT="Warning">
</CENTER>   
<BLOCKQUOTE>
To protect your personal information you should
<B>Exit your Browser completely</B> when finished. See help for details.<BR>
<b>All information viewed while using a ClassNet class is for class use and 
may not be shared with individuals not enrolled in the class.<b>
<BR>If your  name is not on the list, you need to 
<a href="$GLOBALS::SECURE_SERVER_ROOT/cgi-bin/get_stud_reg_form">Join the 
ClassNet class</a> before you can enter it.
</BLOCKQUOTE>
END_FORM
   CN_UTILS::print_cn_footer("get_login.html");
}

1;
