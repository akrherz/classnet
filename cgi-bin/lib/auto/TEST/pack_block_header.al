# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub pack_block_header {
    my (%params) = @_;
    my $hdr = '<CN_BLOCK PTS=';
    ($params{'PP'} > 0) and $hdr .= "$params{'PP'}/";
    $hdr .= $params{'TP'};
    ($params{'Name'}) and $hdr .= " NAME=\"$params{'Name'}\"";
    return $hdr . '>';
}

1;
