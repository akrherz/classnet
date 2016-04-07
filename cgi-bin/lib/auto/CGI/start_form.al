# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub start_form {
    &startform(@_);
}

#### Method: start_multipart_form
# synonym for startform
1;
