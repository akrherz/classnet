# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub EXISTS {
    exists $_[0]->{$_[1]};
}
1;
