# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub remote_addr {
    return $ENV{'REMOTE_ADDR'} || '127.0.0.1';
}

#### Method: script_name
# Return the partial URL to this script for
# self-referencing scripts.  Also see
# self_url(), which returns a URL with all state information
# preserved.
####
1;
