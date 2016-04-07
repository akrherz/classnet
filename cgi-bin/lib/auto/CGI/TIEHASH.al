# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub TIEHASH { 
    return new CGI;
}
1;
