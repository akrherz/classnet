# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub grade_ungraded {
   my ($self) = @_;
   my $dir = $self->{'Ungraded Dir'};
   $self->grade_forecasts($dir,$self->{'Name'});
}

1;
