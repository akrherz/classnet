# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub CLEAR {
    %{$_[0]}=();
}

#### Method: autoescape
# If you won't to turn off the autoescaping features,
# call this method with undef as the argument
####
1;
