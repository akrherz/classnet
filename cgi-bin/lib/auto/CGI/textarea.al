# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub textarea {
    my($self,@p) = @_;
    
    my($name,$default,$rows,$cols,$override,@other) =
        $self->rearrange([NAME,[DEFAULT,VALUE],ROWS,[COLS,COLUMNS],[OVERRIDE,FORCE]],@p);

    my($current)= $override ? $default :
        (defined($self->param($name)) ? $self->param($name) : $default);

    $name = defined($name) ? $self->escapeHTML($name) : '';
    $current = defined($current) ? $self->escapeHTML($current) : '';
    my($r) = $rows ? "ROWS=$rows" : '';
    my($c) = $cols ? "COLS=$cols" : '';
    return qq{<TEXTAREA NAME="$name" $r $c @other>$current</TEXTAREA>};
}

#### Method: button
# Create a javascript button.
# Parameters:
#   $name ->  (optional) Name for the button. (-name)
#   $value -> (optional) Value of the button when selected (and visible name) (-value)
#   $onclick -> (optional) Text of the JavaScript to run when the button is
#                clicked.
# Returns:
#   A string containing a <INPUT TYPE="button"> tag
####
1;
