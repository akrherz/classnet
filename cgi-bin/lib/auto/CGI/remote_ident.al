# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub remote_ident {
    return $ENV{'REMOTE_IDENT'};
}

#### Method: auth_type
# Return the type of use verification/authorization in use, if any.
####
1;
