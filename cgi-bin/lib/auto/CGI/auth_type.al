# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub auth_type {
    return $ENV{'AUTH_TYPE'};
}

#### Method: remote_user
# Return the authorization name used for user
# verification.
####
1;
