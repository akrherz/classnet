# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub write_block {
    my ($self,$b,%params) = @_;
    $hdr = TEST->pack_block_header(%params);
    $fname = "$self->{'Dev Root'}/$b/options";
    open(BLK,">$fname") or
        ERROR::system_error('TEST','write_block','open',$fname);
    print BLK "$hdr\n";
    print BLK $params{'btext'};
    close(BLK);
}

1;
