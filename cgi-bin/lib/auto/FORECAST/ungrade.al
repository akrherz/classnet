# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

#########################################

sub ungrade {
    my ($self) = @_;

    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $file (@files) {
        rename("$self->{'Graded Dir'}/$file","$self->{'Ungraded Dir'}/$file");
    }
}

1;
