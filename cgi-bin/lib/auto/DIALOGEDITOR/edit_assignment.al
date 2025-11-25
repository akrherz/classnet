# NOTE: Derived from lib/DIALOGEDITOR.pm.  Changes made here will be lost.
package DIALOGEDITOR;

sub edit_assignment {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my %params = $asn->read();
    my $atype = $params{'Assignment Type'};
    $publish = $EDITOR::checked[!($asn->{'Dev Root'} =~ /.develop/)];
    TEST->print_test_header("Assignment $asn->{'Name'}");
    $self->print_start_form();
    print <<"ASSIGN";
<INPUT TYPE=hidden NAME="Assignment Type" VALUE="$atype">
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<CENTER>
(Type $atype)
<HR>
<INPUT TYPE=checkbox NAME=publish VALUE=Publish $publish> Publish 
<HR>
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save>
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
ASSIGN
    $self->print_footer();
}

1;









1;
