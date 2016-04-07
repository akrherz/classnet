# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub print_help {
    my ($self,$msg) = @_;
    print <<"HELP";
Content-type: text/html
Window-target: help

<HTML>
<BODY BGCOLOR=#ffffff>
$msg
</BODY>
</HTML>
HELP
    exit(0);
}

1;
