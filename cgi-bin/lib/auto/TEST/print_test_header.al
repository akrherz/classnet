# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub print_test_header {
   my ($title,$window) = @_;
   (!defined $window) and $window = '_top';
print <<"HEADER";
Content-type: text/html
Window-target: $window

<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
<BODY $GLOBALS::BGCOLOR>
<CENTER><H3>$title</H3></CENTER>
HEADER
}

1;
