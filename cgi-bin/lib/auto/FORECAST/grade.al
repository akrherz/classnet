# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub grade {
    my ($self) = @_;

    undef $self->{'Runtime Values'};
    $self->TEST::grade() if (defined($self->get_runtime_values()));
}

1;
