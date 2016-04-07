# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub get_blocks {
    my ($self) = @_;
    opendir(BLOCKS,$self->{'Dev Root'}) or
       	   &ERROR::system_error('TEST','get_blocks','opendir',"$self->{'Dev Root'}");
    my @blocks = grep(/^\d+$/,readdir(BLOCKS));
    close BLOCKS;
    sort {$a <=> $b} @blocks;
}

1;
