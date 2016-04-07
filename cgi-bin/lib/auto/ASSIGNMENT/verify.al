# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub verify {
    my ($self) = @_;
    my $stu = $self->{'Member'};
    my $cls = $self->{'Class'};
    CN_UTILS::print_cn_header("Password Required");

    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/student>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$stu->{'Ticket'}">
<INPUT TYPE=hidden NAME=cn_option VALUE="Verify">
<CENTER>
A password is required to complete this assignment. Please enter below:<P>
<INPUT TYPE=password NAME=proctor VALUE="" SIZE=16><P>
<INPUT TYPE=submit VALUE="Verify">
</CENTER>
FORM
   CN_UTILS::print_cn_footer();
   exit(0);
}

1;
