# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub request_method {
    return $ENV{'REQUEST_METHOD'};
}

#### Method: path_translated
# Return the physical path information provided
# by the URL (if any)
####
1;
