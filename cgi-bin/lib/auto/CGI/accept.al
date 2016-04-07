# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub accept {
    my($self,$search) = @_;
    my(%prefs,$type,$pref,$pat);
    
    my(@accept) = split(',',$ENV{'HTTP_ACCEPT'});
    
    foreach (@accept) {
        ($pref) = /q=(\d\.\d+|\d+)/;
        ($type) = m#(\S+/[^;]+)#;
        next unless $type;
        $prefs{$type}=$pref || 1;
    }

    return keys %prefs unless $search;
    
    # if a search type is provided, we may need to
    # perform a pattern matching operation.
    # The MIME types use a glob mechanism, which
    # is easily translated into a perl pattern match

    # First return the preference for directly supported
    # types:
    return $prefs{$search} if $prefs{$search};

    # Didn't get it, so try pattern matching.
    foreach (keys %prefs) {
        next unless /\*/;       # not a pattern match
        ($pat = $_) =~ s/([^\w*])/\\$1/g; # escape meta characters
        $pat =~ s/\*/.*/g; # turn it into a pattern
        return $prefs{$_} if $search=~/$pat/;
    }
}

#### Method: user_agent
# If called with no parameters, returns the user agent.
# If called with one parameter, does a pattern match (case
# insensitive) on the user agent.
####
1;
