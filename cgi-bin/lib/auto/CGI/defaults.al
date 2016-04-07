# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub defaults {
    my($self,@p) = @_;

    my($label,@other) = $self->rearrange([NAME],@p);

    $label=$self->escapeHTML($label);
    $label = $label || "Defaults";
    my($value) = qq/VALUE="$label"/;
    return qq/<INPUT TYPE="submit" NAME=".defaults" $value @other>/;
}

#### Method: checkbox
# Create a checkbox that is not logically linked to any others.
# The field value is "on" when the button is checked.
# Parameters:
#   $name -> Name of the checkbox
#   $checked -> (optional) turned on by default if true
#   $value -> (optional) value of the checkbox, 'on' by default
#   $label -> (optional) a user-readable label printed next to the box.
#             Otherwise the checkbox name is used.
# Returns:
#   A string containing a <INPUT TYPE="checkbox"> field
####
1;
