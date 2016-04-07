# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub query_string {
    my $self = shift;
    my($param,$value,@pairs);
    foreach $param ($self->param) {
        my($eparam) = &escape($param);
        foreach $value ($self->param($param)) {
            $value = &escape($value);
            push(@pairs,"$eparam=$value");
        }
    }
    return join("&",@pairs);
}

#### Method: accept
# Without parameters, returns an array of the
# MIME types the browser accepts.
# With a single parameter equal to a MIME
# type, will return undef if the browser won't
# accept it, 1 if the browser accepts it but
# doesn't give a preference, or a floating point
# value between 0.0 and 1.0 if the browser
# declares a quantitative score for it.
# This handles MIME type globs correctly.
####
1;
