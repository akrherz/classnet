# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub radio_group {
    my($self,@p) = @_;

    my($self,@p) = @_;

    my($name,$values,$default,$linebreak,$labels,
       $rows,$columns,$rowheaders,$colheaders,$override,$nolabels,@other) =
        $self->rearrange([NAME,[VALUES,VALUE],DEFAULT,LINEBREAK,LABELS,
                          ROWS,[COLUMNS,COLS],
                          ROWHEADERS,COLHEADERS,
                          [OVERRIDE,FORCE],NOLABELS],@p);
    my($result,$checked);

    if (!$override && defined($self->param($name))) {
        $checked = $self->param($name);
    } else {
        $checked = $default;
    }
    # If no check array is specified, check the first by default
    $checked = $values->[0] unless $checked;
    $name=$self->escapeHTML($name);

    my(@elements);
    my(@values) = @$values ? @$values : $self->param($name);
    foreach (@values) {
        my($checkit) = $checked eq $_ ? 'CHECKED' : '';
        my($break) = $linebreak ? '<BR>' : '';
        my($label)='';
        unless (defined($nolabels) && $nolabels) {
            $label = $_;
            $label = $labels->{$_} if defined($labels) && $labels->{$_};
            $label = $self->escapeHTML($label);
        }
        $_=$self->escapeHTML($_);
        push(@elements,qq/<INPUT TYPE="radio" NAME="$name" VALUE="$_" $checkit @other>${label} ${break}/);
    }
    return @elements unless $columns;
    return _tableize($rows,$columns,$rowheaders,$colheaders,@elements);
}

#### Method: popup_menu
# Create a popup menu.
# Parameters:
#   $name -> Name for all the menu
#   $values -> A pointer to a regular array containing the
#             text of each menu item.
#   $default -> (optional) Default item to display
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   A string containing the definition of a popup menu.
####
1;
