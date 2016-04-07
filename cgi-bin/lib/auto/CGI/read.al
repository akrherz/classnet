# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub read {
    my($self,$bytes) = @_;
    # default number of bytes to read
    $bytes = $bytes || $FILLUNIT;       

    # Fill up our internal buffer in such a way that the boundary
    # is never split between reads.
    $self->fillBuffer($bytes);

    # Find the boundary in the buffer (it may not be there).
    my $start = index($self->{BUFFER},$self->{BOUNDARY});

    # If the boundary begins the data, then skip past it
    # and return undef.  The +2 here is a fiendish plot to
    # remove the CR/LF pair at the end of the boundary.
    if ($start == 0) {

        # clear us out completely if we've hit the last boundary.
        if (index($self->{BUFFER},"$self->{BOUNDARY}--")==0) {
            $self->{BUFFER}='';
            $self->{LENGTH}=0;
            return undef;
        }

        # just remove the boundary.
        substr($self->{BUFFER},0,length($self->{BOUNDARY})+2)='';
        return undef;
    }

    my $bytesToReturn;    
    if ($start > 0) {           # read up to the boundary
        $bytesToReturn = $start > $bytes ? $bytes : $start;
    } else {    # read the requested number of bytes
        # leave enough bytes in the buffer to allow us to read
        # the boundary.  Thanks to Kevin Hendrick for finding
        # this one.
        $bytesToReturn = $bytes - (length($self->{BOUNDARY})+1);
    }

    my $returnval=substr($self->{BUFFER},0,$bytesToReturn);
    substr($self->{BUFFER},0,$bytesToReturn)='';
    
    # If we hit the boundary, remove the CRLF from the end.
    return ($start > 0) ? substr($returnval,0,-2) : $returnval;
}

# This fills up our internal buffer in such a way that the
# boundary is never split between reads
1;
