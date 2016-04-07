# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub user_name {
    return $ENV{'HTTP_FROM'} || $ENV{'REMOTE_IDENT'} || $ENV{'REMOTE_USER'};
}

# Return true if we've been initialized with a query
# string.
1;
