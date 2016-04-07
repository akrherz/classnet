# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub textfield {
    my($self,@p) = @_;
    my($name,$default,$size,$maxlength,$override,@other) = 
        $self->rearrange([NAME,[DEFAULT,VALUE],SIZE,MAXLENGTH,[OVERRIDE,FORCE]],@p);

    my $current = $override ? $default : 
        (defined($self->param($name)) ? $self->param($name) : $default);

    $current = defined($current) ? $self->escapeHTML($current) : '';
    $name = defined($name) ? $self->escapeHTML($name) : '';
    my($s) = defined($size) ? qq/SIZE=$size/ : '';
    my($m) = defined($maxlength) ? qq/MAXLENGTH=$maxlength/ : '';
    return qq/<INPUT TYPE="text" NAME="$name" VALUE="$current" $s $m @other>/;
}

#### Method: filefield
# Parameters:
#   $name -> Name of the file upload field
#   $size ->  Optional width of field in characaters.
#   $maxlength -> Optional maximum number of characters.
# Returns:
#   A string containing a <INPUT TYPE="text"> field
#
1;
