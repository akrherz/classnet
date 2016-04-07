# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub script_name {
    return $ENV{'SCRIPT_NAME'} if $ENV{'SCRIPT_NAME'};
    # These are for debugging
    return "/$0" unless $0=~/^\//;
    return $0;
}

#### Method: referer
# Return the HTTP_REFERER: useful for generating
# a GO BACK button.
####
1;
