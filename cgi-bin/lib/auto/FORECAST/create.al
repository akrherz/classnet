# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub create {
    my ($self) = @_;
    ASSIGNMENT->create($self);
    my $dir = $self->{'Dev Root'};
    system("cp -r /local1/weather/Forecast/* $dir");
}

1;
