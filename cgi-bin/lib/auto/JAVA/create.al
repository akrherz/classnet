# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

sub create {
    my ($self) = @_;
    ASSIGNMENT::create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('JAVA.pm','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type>";
    close OPTION;
#    mkdir($self->{'Java Dir'},0700) or
#        ERROR::system_error('JAVA','create','mkdir',$self->{'Java Dir'});
}

1;
