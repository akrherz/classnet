# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub reset {
    my($self,@p) = @_;
    my($label,@other) = $self->rearrange([NAME],@p);
    $label=$self->escapeHTML($label);
    my($value) = $label ? qq/VALUE="$label"/ : '';

    return qq/<INPUT TYPE="reset" $value @other>/;
}

#### Method: defaults
# Create a "defaults" button.
# Parameters:
#   $name -> (optional) Name for the button.
# Returns:
#   A string containing a <INPUT TYPE="submit" NAME=".defaults"> tag
#
# Note: this button has a special meaning to the initialization script,
# and tells it to ERASE the current query string so that your defaults
# are used again!
####
1;
