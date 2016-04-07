# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub start_multipart_form {
    my($self,@p) = @_;
    my($method,$action,$enctype,@other) = 
        $self->rearrange([METHOD,ACTION,ENCTYPE],@p);
    $self->startform($method,$action,$enctype || MULTIPART,@other);
}

#### Method: endform
# End a form
1;
