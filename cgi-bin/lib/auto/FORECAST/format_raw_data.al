# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = '';
    my $name = $self->{'Name'};
    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $fname (@files) {
        $self->{'Student File'} = $fname;
        $body .= TEST->format_raw_data($self,"$sname\t$fname");
    }
    $body;
}

1;
