# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub save {
    my($self,$filehandle) = @_;
    my($param);
    my($package) = caller;
    $filehandle = $filehandle=~/[':]/ ? $filehandle : "$package\:\:$filehandle";
    foreach $param ($self->param) {
        my($escaped_param) = &escape($param);
        my($value);
        foreach $value ($self->param($param)) {
            print $filehandle "$escaped_param=",escape($value),"\n";
        }
    }
}

#### Method: header
# Return a Content-Type: style header
#
####
1;
