# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub upload {
    my ($self,$hfile) = @_;
    my ($header);

    if (!defined $hfile) { 
        ERROR::user_error($ERROR::NOTDONE,"find file <B>$url</B>");
        exit(0);
    }
    
    $hfile =~ s/[^<]*(<CN_ASSIGN TYPE=\w+[^>]*>)/eval { $header = $1; ''}/e;
    my %params = (ref($self))->unpack_assign_header($header);
    if (!defined %params) {
        ERROR::user_error($ERROR::NOTDONE,"upload assignment information: $header");
        exit(0);
    }
    my $tp = ref($self);
    if (!("\U$params{'Assignment Type'}\E" eq $tp)) {
        ERROR::user_error($ERROR::NOTDONE,"upload. Expecting $tp instead of $params{'Assignment Type'}");
        exit(0);
    }
    $self->create();
    $self->write(%params);
    return $hfile;
}

1;
