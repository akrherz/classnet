# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub user_agent {
    my($self,$match)=@_;
    return $ENV{'HTTP_USER_AGENT'} unless $match;
    return ($ENV{'HTTP_USER_AGENT'} =~ /$match/i);
}

#### Method: cookie
# Returns the magic cookie for the session.
# To set the magic cookie for new transations,
# try print $q->header('-Set-cookie'=>'my cookie')
####
1;
