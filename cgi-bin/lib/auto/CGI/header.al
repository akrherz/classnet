# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub header {
    my($self,@p) = @_;

    my($type,$status,$cookie,$target,$expires,@other) = 
        $self->rearrange([TYPE,STATUS,COOKIE,TARGET,EXPIRES],@p);

    # rearrange() was designed for the HTML portion, so we
    # need to fix it up a little.
    foreach (@other) {
        next unless my($header,$value) = /^(.*)=(.*)$/;
        substr($header,1,1000)=~tr/A-Z/a-z/;
        ($value)=$value=~/^"(.*)"$/;
        $_ = "$header: $value";
    }

    $type = $type || 'text/html';
    push(@other,"Pragma: no-cache") if $self->cache();
    my(@header);
    push(@header,"Status: $status") if $status;
    push(@header,"Window-target: $target") if $target;
    # push all the cookies -- there may be several
    if ($cookie) {
        my(@cookie) = ref($cookie) ? @{$cookie} : $cookie;
        foreach (@cookie) {
            push(@header,"Set-cookie: $_");
        }
    }
    push(@header,"Expires: " . &expires($expires)) if $expires;
    push(@header,@other) if @other;
    push(@header,"Content-type: $type");

    my $header = join($CRLF,@header);
    return $header . "${CRLF}${CRLF}";
}

#### Method: cache
# Control whether header() will produce the no-cache
# Pragma directive.
####
1;
