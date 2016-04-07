# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $text = "<B>$asn_name:</B> 0/0<BR>";
   return ($text,0,0);
}

1;
