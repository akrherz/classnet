# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub state {
    &self_url;
}

#### Method: url
# Like self_url, but doesn't return the query string part of
# the URL.
####
1;
