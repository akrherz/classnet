# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_site {
    my ($self) = @_;
    my $status = $self->get_status();
    $fname = '';
    if ($status) {
        $fname = ($status eq 'graded')? 
            $self->{'Graded Dir'}: $self->{'Ungraded Dir'};
        $fname .= "/$self->{'Student File'}";
    } else {
        return;
    }
    $/ = "\n";
    my $site = '';
    open(WEATHER,"<$fname") or return;
    while(<WEATHER>) {
       # this will handle both BLANK(1.1.1) and OPTION/LIST(1.1) questions
       if (/NAME="1.1/) {
           $site = CN_UTILS::remove_spaces(<WEATHER>);
           last;
       }
    }
    close WEATHER;
    return "\U$site";
}

1;
