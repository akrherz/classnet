# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

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
1;
