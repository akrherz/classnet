# NOTE: Derived from lib/INCLASSEDITOR.pm.  Changes made here will be lost.
package INCLASSEDITOR;

sub command {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $query = $asn->{'Query'};
    if ($query->param('back')) {
        my $cls = $asn->{'Class'};
        my $mem = $asn->{'Member'};
        ASSIGNMENT::print_menu($cls,$mem);
        exit(0);
    }
    $_ = $query->param('suboption');
FRAME: {
    /^writing/ &&
        do {
            %params = $asn->read();
            $params{'Assignment Type'} = $query->param('Assignment Type');
            my $tp = $query->param('TP');
            my $cls = $asn->{'Class'};
            my $mem = $asn->{'Member'};
            if ($tp != $params{'TP'}) {
                $params{'TP'} = $tp;
                my @students = $cls->get_mem_names('student');
                foreach $sname (@students) {
                    my $stu = $cls->get_member('',"$sname");
                    my $asn = INCLASS->new($query,$cls,$stu,$self->{'Name'});
                    $asn->read_test();
                    $asn->{'TP'} = $tp;
                    $asn->write_test('graded');
                }
            }
            $asn->write(%params);
            if (defined $query->param('publish')) { 
                $asn->publish();
            } else {
                $asn->unpublish();
            }
            ASSIGNMENT::print_menu($cls,$mem);
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
