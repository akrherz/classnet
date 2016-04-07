# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub referer {
    return $ENV{'HTTP_REFERER'};
}

#### Method: server_name
# Return the name of the server
####
1;
