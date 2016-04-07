# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub path_translated {
    return $ENV{'PATH_TRANSLATED'};
}

#### Method: query_string
# Synthesize a query string from our current
# parameters
####
1;
