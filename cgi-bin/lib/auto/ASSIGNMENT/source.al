# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub source {
    my ($class, $self) = @_;
    # Handle both method and legacy calls
    if (ref($class)) { $self = $class; }
    return $self->get_assign_header();
}

1;
