# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub delete_block {
    my ($self,$b) = @_;
    my $nb = $self->block_count();
    my $cls = $self->{'Class'};
    my $clip = "$cls->{'Root Dir'}/assignments/.develop/.clipb";
    my $dir = $self->{'Dev Root'};
    system "rm -r $clip";
    rename("$dir/$b","$clip") or
        ERROR::system_error('TEST','delete_block','rename',"$dir/$b to $dir/.clipb");
    for ($old = $b + 1; $old <= $nb; $old++) {
        $new = $old - 1;
        rename("$dir/$old","$dir/$new") or
            ERROR::system_error('TEST','delete_block','rename',"$dir/$old to $dir/$new");
    }
}

1;
