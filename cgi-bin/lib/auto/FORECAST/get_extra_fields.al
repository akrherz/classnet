# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_extra_fields {
    my ($self) = @_;
    my $fname = "$self->{'Dev Root'}/archive.dat"; 
    if (-e "$fname") {
        open(WEATHER,"<$fname");
        $data = <WEATHER>;
        close WEATHER;
    } else {
        $data = '';
    }       
    return "<H3>Archived Data</H3><TEXTAREA NAME=data ROWS=10 COLS=60>$data</TEXTAREA><HR>";
}

1;
