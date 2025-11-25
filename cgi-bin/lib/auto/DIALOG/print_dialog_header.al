# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub print_dialog_header {
   my $class = shift;
   # Handle both method and legacy calls
   my ($title, $window) = ($class eq 'DIALOG') ? @_ : ($class, @_);
   (!defined $window) and $window = '_top';
print <<"HEADER";
Content-type: text/html
Window-target: $window

<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
HEADER

}

1;
