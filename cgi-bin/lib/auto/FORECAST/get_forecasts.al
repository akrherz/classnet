# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub get_forecasts {
    my ($dir,$asn_name) = @_;
    my $e_asn_name = CGI::escape($asn_name);

    $dir =~ /^(\/[^\/]*)(\/[^\/]*)(\/[^\/]*)/;
    if (-e "$1$2$3/assignments/$e_asn_name/archive.dat") {
        if (-e "$dir/$e_asn_name") {
            @files = ($e_asn_name);
        } else {
            @files = ();
        }
    } else {
        opendir(FORECASTS,$dir);
        @files = grep(/^\d{2}\w{3}\d{4}$/,readdir(FORECASTS));
        close FORECASTS;
    }
    return @files;
}

1;
