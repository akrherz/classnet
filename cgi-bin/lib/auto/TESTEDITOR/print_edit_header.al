# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub print_edit_header {
    print <<"HEADER";
Content-type: text/html
Window-target: editor

<HTML>
<HEAD>
<META HTTP-EQUIV="Window-target" CONTENT="editor">
</HEAD>
<BODY $GLOBALS::BGCOLOR>
HEADER
}

1;
