# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub new {
    my($package) = @_;
    $SEQUENCE++;
    my $directory = "${TMPDIRECTORY}${SL}${SEQUENCE}";
    return bless \$directory;
}

1;
