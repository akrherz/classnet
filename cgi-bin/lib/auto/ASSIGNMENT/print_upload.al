# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub print_upload {
    my ($self,$cls,$inst) = @_;
    CN_UTILS::print_cn_header("Upload File");
    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SERVER_ROOT/cgi-bin/assignments 
ENCTYPE="multipart/form-data"> <INPUT TYPE=hidden NAME="Class Name" 
VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="cn_option" VALUE="Perform Upload">
<CENTER><H3>$self->{'Name'}</H3></CENTER>
<table align="center" width="50%">
<tr>
<td>
Enter a filename to upload. When you refer to it in your assignment, use 
only the filename, not the local path information.
<p>
Example:<br>
<b>Filename:</b> D:\\class\\images\\test.gif<br>
<b>HTML:</b>&lt;img src="test.gif"&gt;
</td>
</tr>
</table>
<CENTER>
<H4>
<b>FileName:</b><INPUT TYPE=file NAME="FileName" SIZE=40>
<BR>
<INPUT TYPE=submit Value="Upload"> <INPUT TYPE=reset>
<BR>
<INPUT TYPE=submit NAME=back Value="Assignments Menu"> 
</H4>
</CENTER>
FORM
    CN_UTILS::print_cn_footer("assignments.html");
}

1;
