# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub get_wx_filename {
    my ($self) = @_;
    
    my $fname = $self->{'Student File'};
    if ($fname =~ /(\d{2})(\w{3})(\d{4})/) {
        $day = $1; $mon=$2; $year=$3;
        for($i=0;$i < 12 && $mon ne $months[$i]; $i++){};
        $mon = $i;
    } elsif ($fname =~ /(\d{2})(\d{2})(\d{2})/) {
        $day = $1; $mon=$2; $year=$3;
    } else {
        # it is an archived dataset
        return $fname;
    }
    return sprintf("%04d%02d%02d",$year,$mon+1,$day);
}

1;
