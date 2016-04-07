# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub end_html {
    return "</BODY></HTML>";
}

################################
# METHODS USED IN BUILDING FORMS
################################

#### Method: isindex
# Just prints out the isindex tag.
# Parameters:
#  $action -> optional URL of script to run
# Returns:
#   A string containing a <ISINDEX> tag
1;
