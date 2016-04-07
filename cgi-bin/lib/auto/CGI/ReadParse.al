# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub ReadParse {
    local(*in);
    if (@_) {
        *in = $_[0];
    } else {
        my $pkg = caller();
        *in=*{"${pkg}::in"};
    }
    tie(%in,CGI);
}
1;
