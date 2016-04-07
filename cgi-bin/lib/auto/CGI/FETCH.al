# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub FETCH {
    return $_[0] if $_[1] eq 'CGI';
    return join("\0",$_[0]->param($_[1]));
}
1;
