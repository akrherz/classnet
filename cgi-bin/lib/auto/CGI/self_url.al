# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub self_url {
    my($self) = @_;
    my($query_string) = $self->query_string;
    my $name = "http://" . $self->server_name;
    $name .= ":" . $self->server_port
        unless $self->server_port == 80;
    $name .= $self->script_name;
    $name .= $self->path_info if $self->path_info;
    return $name unless $query_string;
    return "$name?$query_string";
}

# This is provided as a synonym to self_url() for people unfortunate
# enough to have incorporated it into their programs already!
1;
