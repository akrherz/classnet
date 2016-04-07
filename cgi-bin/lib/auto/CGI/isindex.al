# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub isindex {
    my($self,@p) = @_;
    my($action,@other) = $self->rearrange([ACTION],@p);
    $action = qq/ACTION="$action"/ if $action;
    return "<ISINDEX $action @other>";
}

#### Method: startform
# Start a form
# Parameters:
#   $method -> optional submission method to use (GET or POST)
#   $action -> optional URL of script to run
#   $enctype ->encoding to use (URL_ENCODED or MULTIPART)
1;
