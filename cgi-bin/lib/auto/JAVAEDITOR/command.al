# NOTE: Derived from lib/JAVAEDITOR.pm.  Changes made here will be lost.
package JAVAEDITOR;

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

1;
