# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub password_field {
    my ($self,@p) = @_;

    my($name,$default,$size,$maxlength,$override,@other) = 
        $self->rearrange([NAME,[DEFAULT,VALUE],SIZE,MAXLENGTH,[OVERRIDE,FORCE]],@p);

    my($current) =  $override ? $default :
        (defined($self->param($name)) ? $self->param($name) : $default);

    $name = defined($name) ? $self->escapeHTML($name) : '';
    $current = defined($current) ? $self->escapeHTML($current) : '';
    my($s) = defined($size) ? qq/SIZE=$size/ : '';
    my($m) = defined($maxlength) ? qq/MAXLENGTH=$maxlength/ : '';
    return qq/<INPUT TYPE="password" NAME="$name" VALUE="$current" $s $m @other>/;
}

#### Method: textarea
# Parameters:
#   $name -> Name of the text field
#   $default -> Optional default value of the field if not
#                already defined.
#   $rows ->  Optional number of rows in text area
#   $columns -> Optional number of columns in text area
# Returns:
#   A string containing a <TEXTAREA></TEXTAREA> tag
#
1;
