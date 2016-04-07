# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub send_edit_form {
    my ($self,$query,$stu) = @_;
    my @students = @{$stu};
    my $tkt = $query->param('Ticket');
    TEST::print_test_header("In-class Scores<BR>$self->{'Name'}");
    print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/gradebook">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$tkt">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
FORM
    $cls = $self->{'Class'};
    my %assign_params = $self->read();
    $assign_params{'PR'} = 0;
    print "<B>Total Points:</B> <INPUT NAME=total SIZE=3 VALUE=$assign_params{'TP'}><HR>\n";
    foreach $sname (@students) {
        my $mem = $cls->get_member('',$sname);
        my $asn = INCLASS->new('',$cls,$mem,$self->{'Name'});
        $asn->read_test();
        my $pr = $asn->{'PR'};
        if ($pr == 0) {
          $pr = '0';
        }
        print "<INPUT NAME=\"stu_$sname\" SIZE=3 VALUE=$pr> $sname<BR>\n";
    }
    print "<CENTER><H4><INPUT TYPE=submit Value=Submit> <INPUT TYPE=reset> 
<INPUT TYPE=submit NAME=cancel VALUE=Cancel></H4></CENTER>";
    CN_UTILS::print_cn_footer();
    exit(0);
}

1;
