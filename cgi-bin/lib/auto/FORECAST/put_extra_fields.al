# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub put_extra_fields {
    my ($self,$query) = @_;
    my $fname = "$self->{'Dev Root'}/archive.dat"; 
    $data = CN_UTILS::remove_spaces($query->param('data'));
    if ($data eq '') {
        unlink($fname);
    } else {
        open(WEATHER,">$fname");
        print WEATHER $data;
        close WEATHER;
    }
}

1;
1;
