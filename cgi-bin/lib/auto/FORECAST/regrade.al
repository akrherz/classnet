# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub regrade {
    my ($self) = @_;
    $self->grade_forecasts($self->{'Graded Dir'});
    $self->grade_forecasts($self->{'Ungraded Dir'});
}

1;
