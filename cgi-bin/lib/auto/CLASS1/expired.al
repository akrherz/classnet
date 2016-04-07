# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub expired {
    my ($self) = @_;
    ($mon,$year) = split(/ /,$self->{'Expiration Month'});
    @monname = ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');
    for ($i=0; $i < 12 && $monname[$i] ne $mon; $i++){};
    $cls_tot = $i + 12 * $year;
    $year = (localtime)[5] + 1900;
    $cur_tot = (localtime)[4] + 12 * $year;
    return $cur_tot >= $cls_tot;  
}

1;
