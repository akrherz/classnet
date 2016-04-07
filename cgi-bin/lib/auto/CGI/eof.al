# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub eof {
    my($self) = @_;
    return 1 if (length($self->{BUFFER}) == 0)
                 && ($self->{LENGTH} <= 0);
}

# utility function -- return TRUE if a read on the filehandle
# blocks for more than the specified timeout.
# NOTE: This piece of code has been commented out because it
# causes problems on Solaris and DEC Unix 3.2 systems (and
# maybe others)
1;
