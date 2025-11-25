# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

#########################################

sub create {
    my ($self) = @_;
    ASSIGNMENT->create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('DIALOG.pm','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type>";
    close OPTION;
#    mkdir($self->{'Dialog Dir'},0700) or
#        ERROR::system_error('DIALOG','create','mkdir',$self->{'Dialog Dir'});
}

1;
