# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub create {
    my ($self) = @_;
    ASSIGNMENT::create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('TEST','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type>";
    close OPTION;
    $self->insert_block(1);
}

1;
