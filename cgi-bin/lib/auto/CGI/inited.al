# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub inited {
    my($self) = shift;
    return $self->{'.init'};
}

# -------------- really private subroutines -----------------

1;
