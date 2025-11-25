# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

#########################################

sub create {
    my ($self) = @_;
    ASSIGNMENT->create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('TEST','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type TP=100>";
    close OPTION;
}

1;
