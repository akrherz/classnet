# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub raw_cookie {
    return $ENV{'HTTP_COOKIE'};
}

#### Method: remote_host
# Return the name of the remote host, or its IP
# address if unavailable.  If this variable isn't
# defined, it returns "localhost" for debugging
# purposes.
####
1;
