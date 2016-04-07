# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub url {
    my($self) = @_;
    my $name = "http://" . $self->server_name;
    $name .= ":" . $self->server_port
        unless $self->server_port == 80;
    $name .= $self->script_name;
    return $name;
}

#### Method: cookie
# Set or read a cookie from the specified name.
# Cookie can then be passed to header().
# Usual rules apply to the stickiness of -value.
#  Parameters:
#   -name -> name for this cookie (required)
#   -value -> value of this cookie (scalar, array or hash) 
#   -path -> paths for which this cookie is valid (optional)
#   -domain -> internet domain in which this cookie is valid (optional)
#   -secure -> if true, cookie only passed through secure channel (optional)
#   -expires -> expiry date in format Wdy, DD-Mon-YY HH:MM:SS GMT (optional)
####
1;
