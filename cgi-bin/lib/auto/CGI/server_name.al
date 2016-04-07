# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub server_name {
    return $ENV{'SERVER_NAME'} || 'dummy.host.name';
}

#### Method: server_port
# Return the tcp/ip port the server is running on
####
1;
