# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub pack_assign_header {
    my ($class,%params) = @_;
    my $hdr = "<CN_ASSIGN ";
    $hdr .= "TYPE=$params{'Assignment Type'} ";
    ($params{'DUE'}) and $hdr .= "DUE=$params{'DUE'} ";
    ($params{'PASSWORD'}) and $hdr .= "PASSWORD=\"$params{'PASSWORD'}\" ";
    $hdr .= ($params{'TP'})? "TP=$params{'TP'} ":"TP=0 ";
    $hdr .= ($params{'VIEW'})? "OPT=VIEW":"OPT=NOVIEW";
    return $hdr . ' >';
}

1;
