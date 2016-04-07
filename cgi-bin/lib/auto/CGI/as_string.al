# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub as_string {
    my($self) = @_;
    return $$self;
}

package CGI;

#####
# subroutine: read_multipart
#
# Read multipart data and store it into our parameters.
# An interesting feature is that if any of the parts is a file, we
# create a temporary file and open up a filehandle on it so that the
# caller can read from it if necessary.
#####
1;
