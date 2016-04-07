# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub read_block {
    my ($self,$b,$no_unpack) = @_;
    my (%params, @bdata);

    # Set input record separator and read the file
    $/ = "\n";

    $fname = "$self->{'Dev Root'}/$b/options";
    open(BLK,"<$fname") or
        ERROR::system_error('TEST','read_block','open',$fname);
    @bdata = <BLK>;
    close(BLK);
    if ($no_unpack) {
       $params{'cn_block'} = shift @bdata;
    }
    else {
       my $header = shift @bdata;
       %params = TEST::unpack_block_header($header);
       (defined %params) or
           ERROR::system_error('TEST','read_block','unpack_block_header',
                               "$fname:$header");
    }

    # Save single string in btext
    $params{'btext'} = join('',@bdata);
    return %params;
}

1;
