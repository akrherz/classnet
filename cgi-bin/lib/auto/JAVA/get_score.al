# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $text = "<B>$asn_name:</B> 0/0<BR>";
   return ($text,0,0);
}

1;
