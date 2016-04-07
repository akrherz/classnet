# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub grade_forecasts {
    my ($self,$dir) = @_;
    my $fname;
    my @files = get_forecasts($dir,$self->{'Name'});
    foreach $fname (@files) {
        $self->{'Student File'} = $fname;
        $self->grade();
    }
}

1;
