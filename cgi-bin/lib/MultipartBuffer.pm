package MultipartBuffer;

# how many bytes to read at a time.  We use
# a 5K buffer by default.
$FILLUNIT = 1024 * 5;
$TIMEOUT = 10*60;       # 10 minute timeout
$SPIN_LOOP_MAX = 100;   # bug fix for some Netscape servers
$CRLF=$CGI::CRLF;


sub new {
    my($package,$boundary,$length,$filehandle) = @_;
    my $IN;
    if ($filehandle) {
        my($package) = caller;
        # force into caller's package if necessary
        $IN = $filehandle=~/[':]/ ? $filehandle : "$package\:\:$filehandle"; 
    }
    $IN = "main::STDIN" unless $IN;

    binmode($IN) if $CGI::needs_binmode;
    
    # If the user types garbage into the file upload field,
    # then Netscape passes NOTHING to the server (not good).
    # We may hang on this read in that case. So we implement
    # a read timeout.  If nothing is ready to read
    # by then, we return.
    return undef if wouldBlock($IN,$TIMEOUT);

    # Netscape seems to be a little bit unreliable
    # about providing boundary strings

    if ($boundary) {
        # Under the MIME spec, the boundary consists of the 
        # characters "--" PLUS the Boundary string
        $boundary = "--$boundary";
        # Read the topmost (boundary) line plus the CRLF
        my($null) = '';
        read($IN,$null,length($boundary)+2);
        $length -= (length($boundary) + 2);
    } else { # otherwise we find it ourselves
        my($old);
        ($old,$/) = ($/,$CRLF); # read a CRLF-delimited line
        $boundary = <$IN>;              
        $length -= length($boundary);
        chomp($boundary);               # remove the CRLF
        $/ = $old;                      # restore old line separator
    }

    my $self = {LENGTH=>$length,
                BOUNDARY=>$boundary,
                IN=>$IN,
                BUFFER=>'',
            };

    $FILLUNIT = length($boundary)
        if length($boundary) > $FILLUNIT;

    return bless $self,$package;
}

# This reads and returns the header as an associative array.
# It looks for the pattern CRLF/CRLF to terminate the header.
sub readHeader {
    my($self) = @_;
    my($end);
    my($ok) = 0;
    do {
        $self->fillBuffer($FILLUNIT);
        $ok++ if ($end = index($self->{BUFFER},"${CRLF}${CRLF}")) >= 0;
        $ok++ if $self->{BUFFER} eq '';
        $FILLUNIT *= 2 if length($self->{BUFFER}) >= $FILLUNIT; 
    } until $ok;

    my($header) = substr($self->{BUFFER},0,$end+2);
    substr($self->{BUFFER},0,$end+4) = '';
    my %return;
    while ($header=~/^([\w-]+): (.*)$CRLF/mog) {
        $return{$1}=$2;
    }
    return %return;
}

# This reads and returns the body as a single scalar value.
sub readBody {
    my($self) = @_;
    my($data);
    my($returnval)='';
    while (defined($data = $self->read)) {
        $returnval .= $data;
    }
    return $returnval;
}

# This will read $bytes or until the boundary is hit, whichever happens
# first.  After the boundary is hit, we return undef.  The next read will
# skip over the boundary and begin reading again;
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
sub eof {
    my($self) = @_;
    return 1 if (length($self->{BUFFER}) == 0)
                 && ($self->{LENGTH} <= 0);
}

# utility function -- return TRUE if a read on the filehandle
# blocks for more than the specified timeout.
# NOTE: This piece of code has been commented out because it
# causes problems on Solaris and DEC Unix 3.2 systems (and
# maybe others)
sub wouldBlock {

    return undef;

    my($handle,$timeout) = @_;
    my($rin) = '';
    vec($rin,fileno($handle),1)=1;
    my($nfound,$timeleft) =
        select($rin,undef,undef,$timeout);
    return !$nfound;
}

1;
