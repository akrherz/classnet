# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_stats {
    my ($self,$stats,$tot) = @_;
    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $fname (@files) {
        $self->{'Student File'} = $fname;
        TEST->get_stats($self,$stats,$tot);
    }
}

1;
