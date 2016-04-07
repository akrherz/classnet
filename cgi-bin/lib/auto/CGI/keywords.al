# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub keywords {
    my($self,@values) = @_;
    # If values is provided, then we set it.
    $self->{'keywords'}=[@values] if @values;
    my(@result) = @{$self->{'keywords'}};
    @result;
}

# These are some tie() interfaces for compatability
# with Steve Brenner's cgi-lib.pl routines
1;
