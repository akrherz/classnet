# NOTE: Derived from lib/INSTRUCTOR.pm.  Changes made here will be lost.
package INSTRUCTOR;

#########################################

sub print_menu {
    my ($self,$cls) = @_;
    my @req_list = $cls->get_mem_names('requests');
    my $req_len = @req_list;
    my $msg = '';
    if ($req_len > 0) {
       	$msg .= "<font color=#a40000>Enrollment approval required (see Members)</font><BR>";
    }
    $msg .= $cls->last_access();
    CN_UTILS::print_cn_header("Instructor Menu");
    print <<"FORM";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/instructor>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<H3><CENTER>$cls->{'Name'}</H3>
<H4>
<INPUT TYPE=submit  NAME=cn_option VALUE=Members>
<INPUT TYPE=submit  NAME=cn_option VALUE=Assignments>
<INPUT TYPE=submit  NAME=cn_option VALUE=Gradebook>
<BR>
<INPUT TYPE=submit  NAME=cn_option VALUE="Class Options">
<INPUT TYPE=submit  NAME=cn_option VALUE="Personal Data">
<P><B>Communication</B><BR>
<INPUT TYPE=submit  NAME=cn_option VALUE=Email>
<INPUT TYPE=submit  NAME=cn_option VALUE=Discuss>
<INPUT TYPE=submit  NAME=cn_option VALUE="Edit Discussion">
<INPUT TYPE=submit  NAME=cn_option VALUE=Chat>
<P>
<INPUT TYPE=submit  NAME=cn_option VALUE="Logout">
</H4>
</FORM>
</CENTER>
$msg
FORM
    CN_UTILS::print_cn_footer("instructor_menu.html");
}

1;







1;
