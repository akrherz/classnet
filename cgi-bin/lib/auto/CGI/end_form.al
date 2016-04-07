# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub end_form {
    &endform(@_);
}

#### Method: textfield
# Parameters:
#   $name -> Name of the text field
#   $default -> Optional default value of the field if not
#                already defined.
#   $size ->  Optional width of field in characaters.
#   $maxlength -> Optional maximum number of characters.
# Returns:
#   A string containing a <INPUT TYPE="text"> field
#
1;
