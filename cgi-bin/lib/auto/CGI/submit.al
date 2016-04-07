# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub submit {
    my($self,@p) = @_;

    my($label,$value,@other) = $self->rearrange([NAME,VALUE],@p);

    $label=$self->escapeHTML($label);
    $value=$self->escapeHTML($value);

    my($name) = 'NAME=".submit"';
    $name = qq/NAME="$label"/ if $label;
    $value = $value || $label;
    my($val) = '';
    $val = qq/VALUE="$value"/ if $value;
    return qq/<INPUT TYPE="submit" $name $val @other>/;
}

#### Method: reset
# Create a "reset" button.
# Parameters:
#   $name -> (optional) Name for the button.
# Returns:
#   A string containing a <INPUT TYPE="reset"> tag
####
1;
