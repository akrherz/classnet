# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub submit_edit_changes {
    my ($self,$query) = @_;
    my $cls = $self->{'Class'};
    my $asn = INCLASS->new($query,$cls,'',$self->{'Name'});
    my %params = $asn->read();
    $tp = $query->param('total');
    $params{'TP'} = $tp;
    $self->write(%params);
    # verify that points given is between 0 and total points
    foreach $tname ($query->param()) {
        if ($tname =~ /stu_(.*)/) {
            my $pr = $query->param($tname);
            if ($tp > 0) {
                if  ($pr < 0 or $pr > $tp) {
                     ERROR::user_error($ERROR::NOTDONE,"save points 
because the points received for $1 is not between 0 and $tp");
                }
            } else {
                if  ($pr > 0 or $pr < $tp) {
                     ERROR::user_error($ERROR::NOTDONE,"save points because
the points received for $1 is not between $tp and 0");
                }
            }
        }
    }
    foreach $tname ($query->param()) {
        if ($tname =~ /stu_(.*)/) {
            my $mem = $cls->get_member('',"$1");
            my $asn = INCLASS->new($query,$cls,$mem,$self->{'Name'});
            my $pr = $query->param($tname);
            $asn->{'TP'} = $tp;
            $asn->{'PR'} = $pr;
            $asn->write_test('graded');
        }
    }
}

1;
