# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

# Modify the applet params
# SRM_ALIAS must be defined in srm.conf of ClassNet's httpd server
#    - this allows server document retrieval in other directories
# BASE HREF must be added to the document
# All % signs for codebase must be converted to hex rep. of %25
sub check_java {
    my ($self,$btext,$mode) = @_;
    if ($btext =~ /<APPLET/i) {
	my $code_base = '';
        # add /.develop/ if not published
        if ($self->{'Dev Root'} =~ /.develop/) {
            $code_base = "$GLOBALS::SRM_ALIAS";
        }
	else {
            $code_base = "$GLOBALS::SRM_ALIAS";
	}
        $code_base =~ s/%/%25/g;
        $btext =~ s/<APPLET/<APPLET/i;
        my $param_str =<<"PARAMS";
<param name="mode" value="$mode">
<param name="filePath" value="$self->{'Java Dir'}">
PARAMS
        $btext =~ s/<\/APPLET>/$param_str<\/APPLET>/i;
    }
    return $btext;
}

1;




1;
