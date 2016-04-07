# NOTE: Derived from lib/INCLASSEDITOR.pm.  Changes made here will be lost.
package INCLASSEDITOR;

sub edit_assignment {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my %params = $asn->read();
    my $atype = $params{'Assignment Type'};
    my $tp = $params{'TP'};
    $publish = $EDITOR::checked[!($asn->{'Dev Root'} =~ /.develop/)];
    TEST::print_test_header("Assignment $asn->{'Name'}");
    $self->print_start_form();
    print <<"ASSIGN";
<INPUT TYPE=hidden NAME="Assignment Type" VALUE="$atype">
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<CENTER>
(Type $atype)
<HR>
<INPUT TYPE=checkbox NAME=publish VALUE=Publish $publish> Publish 
<HR>
Total Points
 <INPUT NAME=TP SIZE=3 VALUE=$tp><BR>
<HR>
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save>
<INPUT TYPE=reset  NAME=reset VALUE=Reset> 
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
ASSIGN
    $self->print_footer();
}

1;









1;
