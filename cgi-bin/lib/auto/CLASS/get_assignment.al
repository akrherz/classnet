# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub get_assignment {
    my ($self,$query,$mem,$asn_name) = @_;
    $asn_name or $asn_name = $query->param('Assignment Name');
    if (defined $asn_name) {
        # find the assignment type
        my %asn_info = ASSIGNMENT::get_info($self,$asn_name);
        my $asn_type = $asn_info{'Assignment Type'};
        if ($asn_type) {
            return ($asn_type)->new($query,$self,$mem,$asn_name);
        } else {
            ERROR::user_error($ERROR::NOASNTYPE, $asn_name);
        }
    }
}

1;
