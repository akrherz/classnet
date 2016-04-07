# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub DELETE {
    $_[0]->delete($_[1]);
}
1;
