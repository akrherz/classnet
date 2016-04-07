# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub _tableize {
    my($rows,$columns,$rowheaders,$colheaders,@elements) = @_;
    my($result);

    $rows = int(0.99 + @elements/$columns) unless $rows;
    # rearrange into a pretty table
    $result = "<TABLE>";
    my($row,$column);
    unshift(@$colheaders,'') if @$colheaders && @$rowheaders;
    $result .= "<TR><TH>" . join ("<TH>",@{$colheaders}) if @{$colheaders};
    for ($row=0;$row<$rows;$row++) {
        $result .= "<TR>";
        $result .= "<TH>$rowheaders->[$row]" if @$rowheaders;
        for ($column=0;$column<$columns;$column++) {
            $result .= "<TD>" . $elements[$column*$rows + $row];
        }
    }
    $result .= "</TABLE>";
    return $result;
}

#### Method: radio_group
# Create a list of logically-linked radio buttons.
# Parameters:
#   $name -> Common name for all the buttons.
#   $values -> A pointer to a regular array containing the
#             values for each button in the group.
#   $default -> (optional) Value of the button to turn on by default.  Pass '-'
#               to turn _nothing_ on.
#   $linebreak -> (optional) Set to true to place linebreaks
#             between the buttons.
#   $labels -> (optional)
#             A pointer to an associative array of labels to print next to each checkbox
#             in the form $label{'value'}="Long explanatory label".
#             Otherwise the provided values are used as the labels.
# Returns:
#   An ARRAY containing a series of <INPUT TYPE="radio"> fields
####
1;
