# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub DESTROY {
    my($self) = @_;
    unlink $$self;              # get rid of the file
}

1;
