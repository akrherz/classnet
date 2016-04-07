# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub cookie {
    my($self,@p) = @_;
    my($name,$value,$path,$domain,$secure,$expires,$override) =
        $self->rearrange([NAME,[DEFAULT,VALUE,VALUES],PATH,DOMAIN,SECURE,
                          EXPIRES,[OVERRIDE,FORCE]],@p);
    # if no value is supplied, then we retrieve the
    # value of the cookie, if any.  For efficiency, we cache the parsed
    # cookie in our state variables.
    unless ($value) {
        unless ($self->{'.cookies'}) {
            my(@pairs) = split("; ",$self->raw_cookie);
            foreach (@pairs) {
                my($key,$value) = split("=");
                my(@values) = map unescape($_),split('&',$value);
                $self->{'.cookies'}->{unescape($key)} = [@values];
            }
        }
        return wantarray ? @{$self->{'.cookies'}->{$name}} : $self->{'.cookies'}->{$name}->[0];
    }
    my(@values);
    # pull out our parameters
    if ($self->param($name) && !$override) {
        @values = map escape($_),$self->param($name);
    } else {
        @values = map escape($_),
                  ref($value) eq 'ARRAY' ? @$value : (ref($value) eq 'HASH' ? %$value : $value);
    }

    my(@constant_values);
    push(@constant_values,"domain=$domain") if $domain;
    push(@constant_values,"path=$path") if $path;
    push(@constant_values,"expires=".&expires($expires)) if $expires;
    push(@constant_values,'secure') if $secure;

    my($key) = &escape($name);
    my($cookie) = join("=",$key,join("&",@values));
    return join("; ",$cookie,@constant_values);
}

# This internal routine creates an expires string exactly some number of
# hours from the current time in GMT.  This is the format
# required by Netscape cookies, and I think it works for the HTTP
# Expires: header as well.
1;
