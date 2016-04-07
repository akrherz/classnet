# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub get_graded_form {
    my $self = shift;
    $self->read_test();
    my $pr = $self->{'PR'};
    my $tp = $self->{'TP'};
    return "<B>Score:</B> $pr of $tp (No answers available for In-class assignments)"; 
}

1;
