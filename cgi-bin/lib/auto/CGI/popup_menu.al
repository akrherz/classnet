# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub popup_menu {
    my($self,@p) = @_;

    my($name,$values,$default,$labels,$override,@other) =
        $self->rearrange([NAME,[VALUES,VALUE],[DEFAULT,DEFAULTS],LABELS,[OVERRIDE,FORCE]],@p);
    my($result,$selected);

    if (!$override && defined($self->param($name))) {
        $selected = $self->param($name);
    } else {
        $selected = $default;
    }

    $name=$self->escapeHTML($name);
    $result = qq/<SELECT NAME="$name" @other>\n/;
    foreach (@{$values}) {
        my($selectit) = defined($selected) ? ($selected eq $_ ? 'SELECTED' : '' ) : '';
        my($label) = $_;
        $label = $labels->{$_} if defined($labels) && $labels->{$_};
        my($value) = $self->escapeHTML($_);
        $label=$self->escapeHTML($label);
        $result .= "<OPTION $selectit VALUE=\"$value\">$label\n";
    }

    $result .= "</SELECT>\n";
    return $result;
}

#### Method: scrolling_list
# Create a scrolling list.
# Parameters:
#   $name -> name for the list
#   $values -> A pointer to a regular array containing the
#             values for each option line in the list.
#   $defaults -> (optional)
#             1. If a pointer to a regular array of options,
#             then this will be used to decide which
#             lines to turn on by default.
#             2. Otherwise holds the value of the single line to turn on.
#   $size -> (optional) Size of the list.
#   $multiple -> (optional) If set, allow multiple selections.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing the definition of a scrolling list.
####
1;
