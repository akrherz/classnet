# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub button {
    my($self,@p) = @_;

    my($label,$value,$script,@other) = $self->rearrange([NAME,VALUE,[ONCLICK,SCRIPT]],@p);

    $label=$self->escapeHTML($label);
    $value=$self->escapeHTML($value);
    $script=$self->escapeHTML($script);

    my($name) = '';
    $name = qq/NAME="$label"/ if $label;
    $value = $value || $label;
    my($val) = '';
    $val = qq/VALUE="$value"/ if $value;
    $script = qq/ONCLICK="$script"/ if $script;
    return qq/<INPUT TYPE="button" $name $val $script @other>/;
}

#### Method: submit
# Create a "submit query" button.
# Parameters:
#   $name ->  (optional) Name for the button.
#   $value -> (optional) Value of the button when selected.
# Returns:
#   A string containing a <INPUT TYPE="submit"> tag
####
1;
