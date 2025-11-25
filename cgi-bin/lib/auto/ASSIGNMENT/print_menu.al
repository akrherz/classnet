# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub print_menu {
    my ($class, $cls, $inst) = @_;
    # Handle both method and legacy calls
    if (ref($class)) { $inst = $cls; $cls = $class; }
    CN_UTILS::print_cn_header("Assignments");
    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SERVER_ROOT/cgi-bin/assignments>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3>
FORM
    &print_listbox($cls,'all');
    print <<"FORM";
<P>
<H4>
<INPUT TYPE=submit NAME=cn_option VALUE=Edit>
<INPUT TYPE=submit NAME=cn_option VALUE=Delete>
<INPUT TYPE=submit NAME=cn_option VALUE=Add>
<INPUT TYPE=submit NAME=cn_option VALUE=Mail>
<INPUT TYPE=submit NAME=cn_option VALUE=Upload>
<BR>
<INPUT TYPE=submit NAME=cn_option VALUE="Instructor Menu">
</H4>
</CENTER>
FORM
    CN_UTILS::print_cn_footer("assignments.html");
}

1;
