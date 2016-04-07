# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_names {
    my ($self,$status) = @_;
    my @gfiles = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    my @ufiles = get_forecasts($self->{'Ungraded Dir'},$self->{'Name'});
    push(@gfiles,@ufiles);
    ($status eq 'existing')? @gfiles : ();
}

1;
