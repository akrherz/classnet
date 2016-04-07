# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $mem = $cls->get_member('',$stud_name);
   my $asn = INCLASS->new('',$cls,$mem,$asn_name);
   $asn->read_test();
   my $tp = $asn->{'TP'};
   my $pr = $asn->{'PR'};
   my $text = "<B>$asn_name:</B> $pr/$tp<BR>";
   return ($text,$tp,$pr);
}

1;
