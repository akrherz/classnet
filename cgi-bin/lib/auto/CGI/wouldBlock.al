# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub wouldBlock {

    return undef;

    my($handle,$timeout) = @_;
    my($rin) = '';
    vec($rin,fileno($handle),1)=1;
    my($nfound,$timeleft) =
        select($rin,undef,undef,$timeout);
    return !$nfound;
}

package TempFile;

# Create a temporary file that will be automatically
# unlinked when finished.
# MACPERL users see the note below!
1;
