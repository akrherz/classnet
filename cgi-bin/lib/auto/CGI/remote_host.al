# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub remote_host {
    return $ENV{'REMOTE_HOST'} || $ENV{'REMOTE_ADDR'} 
    || 'localhost';
}

#### Method: remote_addr
# Return the IP addr of the remote host.
####
1;
