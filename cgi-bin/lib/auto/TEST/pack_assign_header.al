# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub pack_assign_header {
    my ($class,%params) = @_;
    $hdr = ASSIGNMENT->pack_assign_header(%params);
    ($hdr =~ /(.+) >/) and $hdr = $1;
    $hdr .= ($params{'FILL'})? ",FILL":",NOFILL"; 
    $hdr .= ($params{'VERS'} > 0)? ",VERS=$params{'VERS'}":'';
    $hdr .= ($params{'MULT'})? ",MULT":''; 
    return $hdr . ' >';
}

1;
