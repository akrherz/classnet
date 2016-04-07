# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub remote_user {
    return $ENV{'REMOTE_USER'};
}

#### Method: user_name
# Try to return the remote user's name by hook or by
# crook
####
1;
