# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub scrolling_list {
    my($self,@p) = @_;
    my($name,$values,$defaults,$size,$multiple,$labels,$override,@other)
        = $self->rearrange([NAME,[VALUES,VALUE],[DEFAULTS,DEFAULT],
                            SIZE,MULTIPLE,LABELS,[OVERRIDE,FORCE]],@p);

    my($result);
    $size = $size || scalar(@{$values});

    my(%selected) = $self->previous_or_default($name,$defaults,$override);

    my($is_multiple) = $multiple ? 'MULTIPLE' : '';
    my($has_size) = $size ? "SIZE=$size" : '';
    $name=$self->escapeHTML($name);
    $result = qq/<SELECT NAME="$name" $has_size $is_multiple @other>\n/;
    my(@values) = @$values ? @$values : $self->param($name);
    foreach (@values) {
        my($selectit) = $selected{$_} ? 'SELECTED' : '';
        my($label) = $_;
        $label = $labels->{$_} if defined($labels) && $labels->{$_};
        $label=$self->escapeHTML($label);
        my($value)=$self->escapeHTML($_);
        $result .= "<OPTION $selectit VALUE=\"$value\">$label\n";
    }
    $result .= "</SELECT>\n";
    return $result;
}

#### Method: hidden
# Parameters:
#   $name -> Name of the hidden field
#   @default -> (optional) Initial values of field (may be an array)
#      or
#   $default->[initial values of field]
# Returns:
#   A string containing a <INPUT TYPE="hidden" NAME="name" VALUE="value">
####
1;
