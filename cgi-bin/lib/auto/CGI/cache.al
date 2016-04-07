# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub cache {
    my($self,$new_value) = @_;
    $new_value = '' unless $new_value;
    if ($new_value ne '') {
        $self->{'cache'} = $new_value;
    }
    return $self->{'cache'};
}

#### Method: redirect
# Return a Location: style header
#
####
1;
