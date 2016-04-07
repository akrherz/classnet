# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub fillBuffer {
    my($self,$bytes) = @_;
    my($boundaryLength) = length($self->{BOUNDARY});
    my($bufferLength) = length($self->{BUFFER});
    my($bytesToRead) = $bytes - $bufferLength + $boundaryLength + 2;
    $bytesToRead = $self->{LENGTH} if $self->{LENGTH} < $bytesToRead;

    # Client may have aborted.  Make sure we time out if the read
    # will block for more than TIMEOUT seconds.
    die "CGI.pm: Client timed out during multipart read.\n" if wouldBlock($self->{IN},$TIMEOUT);
    my $bytesRead = read($self->{IN},$self->{BUFFER},$bytesToRead,$bufferLength);
    
    # An apparent bug in the Netscape Commerce server causes the read()
    # to return zero bytes repeatedly without blocking if the
    # remote user aborts during a file transfer.  I don't know how
    # they manage this, but the workaround is to abort if we get
    # more than SPIN_LOOP_MAX consecutive zero reads.
    if ($bytesRead == 0) {
        die  "CGI.pm: Server closed socket during multipart read (client aborted?).\n"
            if ($self->{ZERO_LOOP_COUNTER}++ >= $SPIN_LOOP_MAX);
    } else {
        $self->{ZERO_LOOP_COUNTER}=0;
    }

    $self->{LENGTH} -= $bytesRead;
}

# Return true when we've finished reading
1;
