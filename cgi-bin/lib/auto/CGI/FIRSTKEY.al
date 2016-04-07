# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub FIRSTKEY {
    $_[0]->{'.iterator'}=0;
    $_[0]->{'.parameters'}->[$_[0]->{'.iterator'}++];
}
1;
