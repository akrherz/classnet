# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub owner {
    my ($self) = @_;
    %inst_info = $self->get_cls_mem_info('instructor');
    foreach $name (keys %inst_info) {
        $priv = $inst_info{$name}[2];
        if ($priv =~ /owner/) {
            return INSTRUCTOR->new(NIL,$self,$name);
        }
    }

}

1;
