# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub print_add_form {
   my ($cls, $inst) = @_;

   # Get the form;
   CN_UTILS::print_cn_header("Add Assignment");
   print "<CENTER><H3>$cls->{'Name'}</H3></CENTER>\n";
   print <<"HTML";
<FORM ENCTYPE="multipart/form-data" METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/assignments>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Add Assign">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<BLOCKQUOTE>
Enter the name of the assignment and select its type. You may optionally specify an
input file. Click on <B>Add</B> when done.
<PRE>
HTML
print "<B>       Type:</B> ";
ASSIGNMENT->print_types('TEST');
    print <<"HTML";
<B>       Name:</B> <INPUT TYPE=text NAME="Assignment Name" SIZE=15 MAXLENGTH=15>
</PRE>
<P>
<CENTER><H4>
<img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif">
Publish Options</H4></CENTER>
<MENU>
<INPUT TYPE=radio NAME=publish VALUE="P">Make available to
students immediately(publish) <BR>
<INPUT TYPE=radio NAME=publish VALUE="N" CHECKED>Put in development folder on
ClassNet and publish later
</MENU>
<CENTER><H4>Loading from an Initial File(optional)</H4></CENTER>
If you have <a
href="http://classnet.cc.iastate.edu/help/maketest.html">prepared a
file</a> in a Web directory or on your local computer, you may specify
its name below and load it into ClassNet.
<UL>
<LI>If the file is on your own computer, fill in the Initial File field.
<LI>If the file is in a Web-accessible directory, fill in Initial URL field.
<LI>Leave both blank if you don't have a file.
<LI>Fill in only one of the two.
</UL>
<PRE>
<B>Initial URL: </B> <INPUT TYPE=text NAME="Initial URL" SIZE=40>
<B>Initial File:</B> <INPUT TYPE=file NAME="Initial File" SIZE=40>
</PRE>
</BLOCKQUOTE>
<CENTER>
<H4>
<INPUT TYPE=submit Value=Add> <INPUT TYPE=reset>
<BR>
<INPUT TYPE=submit NAME=back Value="Assignments Menu"> 
</CENTER>
</H4>
</FORM>
<P>
HTML
   CN_UTILS::print_cn_footer("add_assignment.html");
}

1;
