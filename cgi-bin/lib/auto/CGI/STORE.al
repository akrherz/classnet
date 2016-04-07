# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub STORE {
    $_[0]->param($_[1],split("\0",$_[2]));
}
1;
