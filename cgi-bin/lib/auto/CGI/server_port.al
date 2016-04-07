# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub server_port {
    return $ENV{'SERVER_PORT'} || 80; # for debugging
}

#### Method: remote_ident
# Return the identity of the remote user
# (but only if his host is running identd)
####
1;
