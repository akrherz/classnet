# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub block_count {
    my ($self) = @_;
    opendir(BLOCKS,$self->{'Dev Root'});
    my $n = grep(/^\d+$/,readdir(BLOCKS));
    close BLOCKS;
    return $n;
}

1;
