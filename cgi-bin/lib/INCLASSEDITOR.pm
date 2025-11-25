package INCLASSEDITOR;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader, EDITOR);
#@ISA = qw( EDITOR );
#
# handles editing of tests
#

#########
=head1 INCLASSEDITOR

=head1 Methods:

=cut
#########


require INCLASS;
require EDITOR;

# Prevent AutoLoader from looking for DESTROY.al
sub DESTROY { }

__END__

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
    my $tp = $params{'TP'};
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









