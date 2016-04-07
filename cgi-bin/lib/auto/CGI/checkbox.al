# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub checkbox {
    my($self,@p) = @_;

    my($name,$checked,$value,$label,$override,@other) = 
        $self->rearrange([NAME,[CHECKED,SELECTED,ON],VALUE,LABEL,[OVERRIDE,FORCE]],@p);

    if (!$override && $self->inited) {
        $checked = $self->param($name) ? 'CHECKED' : '';
        $value = defined $self->param($name) ? $self->param($name) :
            (defined $value ? $value : 'on');
    } else {
        $checked = defined($checked) ? 'CHECKED' : '';
        $value = defined $value ? $value : 'on';
    }
    my($the_label) = defined $label ? $label : $name;
    $name = $self->escapeHTML($name);
    $value = $self->escapeHTML($value);
    $the_label = $self->escapeHTML($the_label);
    return <<END;
<INPUT TYPE="checkbox" NAME="$name" VALUE="$value" $checked @other>$the_label
END
}

#### Method: checkbox_group
# Create a list of logically-linked checkboxes.
# Parameters:
#   $name -> Common name for all the check boxes
#   $values -> A pointer to a regular array containing the
#             values for each checkbox in the group.
#   $defaults -> (optional)
#             1. If a pointer to a regular array of checkbox values,
#             then this will be used to decide which
#             checkboxes to turn on by default.
#             2. If a scalar, will be assumed to hold the
#             value of a single checkbox in the group to turn on. 
#   $linebreak -> (optional) Set to true to place linebreaks
#             between the buttons.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   An ARRAY containing a series of <INPUT TYPE="checkbox"> fields
####
1;
