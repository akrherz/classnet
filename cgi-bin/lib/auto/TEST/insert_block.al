# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub insert_block {
    my ($self,$b) = @_;
    $dir = $self->{'Dev Root'};
    $nb = $self->block_count();
    if ($b < 1 || $b > ($nb + 1)) {
        return;
    }
    # rename remaining blocks upward and then insert
    for ($old = $nb; $old >= $b; $old--) {
        $new = $old + 1;
        rename("$dir/$old","$dir/$new");
    }
    mkdir("$dir/$b",0700) or
        ERROR::system_error('TEST','insert_block','mkdir',"$dir/$b");
    open(OPTION,">$dir/$b/options") or
        ERROR::system_error('TEST','insert_block','open',"$dir/$b/options");
    print OPTION "<CN_BLOCK NAME=\"new block\">\n";
    close OPTION;
    $self->insert_question($b,1);
}

1;
