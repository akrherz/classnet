package DIALOGEDITOR;
use Exporter;
@ISA = (Exporter, EDITOR);
#
# handles editing of tests
#

#########
=head1 DIALOGEDITOR

=head1 Methods:

=cut
#########


require DIALOG;
require EDITOR;

#########################################
=head2 open()

=over 4

=item Description
start the editor for this assignment

=item Params
none

=item Returns
none

=back

=cut

sub open {
    my ($self) = @_;
    $self->edit_assignment();
}

#########################################
=head2 command()

=over 4

=item Description
Process an edit command

=item Params
none

=item Returns
none

=back

=cut

sub command {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $query = $asn->{'Query'};
    if ($query->param('back')) {
        my $cls = $asn->{'Class'};
        my $mem = $asn->{'Member'};
        ASSIGNMENT->print_menu($cls,$mem);
        exit(0);
    }
    $_ = $query->param('suboption');
FRAME: {
    /^writing/ &&
        do {
            if (defined $query->param('publish')) { 
                $asn->publish();
            } else {
                $asn->unpublish();
            }
            my $cls = $asn->{'Class'};
            my $mem = $asn->{'Member'};
            ASSIGNMENT->print_menu($cls,$mem);
            exit(0);
            last FRAME;
           };
    }
}

#########################################
=head2 edit_assignment()

=over 4

=item Description
Edit the assignment options file

=item Params
none

=item Returns
ASSIGNMENT object

=back

=cut

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









