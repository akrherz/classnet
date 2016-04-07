# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub path_info {
    return $ENV{'PATH_INFO'};
}

#### Method: request_method
# Returns 'POST', 'GET', 'PUT' or 'HEAD'
####
1;
