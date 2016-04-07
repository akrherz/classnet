# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub startform {
    my($self,@p) = @_;

    my($method,$action,$enctype,@other) = 
        $self->rearrange([METHOD,ACTION,ENCTYPE],@p);

    $method = $method || 'POST';
    $enctype = $enctype || URL_ENCODED;
    $action = $action ? qq/ACTION="$action"/ : '';
    return qq/<FORM METHOD="$method" $action ENCTYPE=$enctype @other>\n/;
}

#### Method: start_form
# synonym for startform
1;
