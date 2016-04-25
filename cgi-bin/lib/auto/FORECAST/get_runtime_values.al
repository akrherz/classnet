# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_runtime_values {
    my ($self) = @_;
    (defined $self->{'Runtime Values'}) and
        return %{$self->{'Runtime Values'}};
    my $fname = $self->get_wx_filename();
    if ($fname =~ /^\d{4}\d{2}\d{2}$/) {
        $site = $self->get_site();
        # check to see if it is in cache
        $cachename = "$CACHE/$site.$fname";
        $rawfile = "$RAWDIR/$fname.out";
    } else {
        $cachename = "$CACHE/$fname";
        $rawfile = "$RAWDIR/$fname.out";
    }
    my %values = {};
    $/ = "\n";
    # use the cache file if there is no raw datafile or the date of
    # the cache is more recent than the rawfile
    if (-e $cachename && (!(-e $rawfile) || (-M $cachename) <= (-M $rawfile))) {
        open(WEATHER,"<$cachename");
        flock(WEATHER,$LOCK_EX);
        while (<WEATHER>) {
            chop;
            ($key,$data) = split('=');
            $values{$key} = $data;
        }
        flock(WEATHER,$LOCK_UN);
        close WEATHER;
    } else {
        # if not in cache then look for raw data file and just return
        # if not present. otherwise, create cache file.
        if (!(-e $rawfile)) { return; };
        open(RAW,"<$rawfile") or return;
        open(WEATHER,">$cachename");
        flock(WEATHER,$LOCK_EX);
        my $store = 0;
        while (<RAW>) {
            chop;
            ($key,$data) = split('=');
            if ($key eq 'STATION') {
                $data = "\U$data";
                $store = ($data =~ $site)? 1: 0;
            }
            if ($store) {
                $values{$key} = $data;
                print WEATHER "$key=$data\n";
            }
        }
        flock(WEATHER,$LOCK_UN);
        close WEATHER;
        close RAW;
        clear_cache();
    }
    $self->{'Runtime Values'} = \%values;
    return %values;
}

1;
