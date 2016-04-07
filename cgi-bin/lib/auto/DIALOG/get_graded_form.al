# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub get_graded_form {
    my $self = shift;
    return "<B>$self->{'Name'}: No correct answers for Dialog assignments</B>"; 
}

1;
