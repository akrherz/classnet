# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub autoEscape {
    my($self,$escape) = @_;
    $self->{'dontescape'}=!$escape;
}

#### Method: version
# Return the current version
####
1;
