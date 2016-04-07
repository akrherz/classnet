# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $escaped_asn_name = CGI::escape($asn_name);
   my $escaped_stud_name = CGI::escape($stud_name);

   # Set input record separator and read the file
   $/ = "\n";

   my $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/graded/$escaped_asn_name";
   my $text = '';
   my $pr = '-';
   if (-e $path) {
       open(ASN,"<$path") or
           ERROR::system_error("TEST","get_score","open",$path);
       flock(ASN,$LOCK_EX);
       my $test_header = <ASN>;
       flock(ASN,$LOCK_UN);
       close(ASN);
       my %scores = TEST::unpack_stud_test_header($test_header);
       (defined %scores) or
            ERROR::system_error('TEST','get_score','unpack stheader',
                                "$path:$test_header");
       $tp = $scores{'TP'};
       $pr = $scores{'PR'};
       my $seen = $scores{'SEEN'};
       if (defined $seen) {
          $text .= "<BR>First Seen on $seen";
       }
       my $subdate = $scores{'SUBDATE'};
       if (defined $subdate) {
          $text .= "<BR>Submitted on $subdate";
       }
       my $date = CN_UTILS::getTime($path); 
       if ($scores{'SUBMIT'} == 2) {
         $pr = '?';
         $text .= " (awaiting grading by instructor)<BR>";
       } else {
         $text .= "<BR>Graded on $date<BR>";
       }
       $text = "<B>$asn_name:</B> $pr/$tp$text";
  }
   else { 
       $path = "$cls->{'Root Dir'}/assignments/$escaped_asn_name/options";
       open(ASN,"<$path") or
           ERROR::system_error('TEST','read','open',$path);
       my $adata = <ASN>;
       close(ASN);
       $adata =~ m/<CN_ASSIGN.*\sTP="?(\d+)/i;
       $tp = $1;
       $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/ungraded/$escaped_asn_name";
       if (-e $path) {
           my $date = CN_UTILS::getTime($path);
           open(ASN,"<$path") or
               ERROR::system_error('TEST','read','open',$path);
           my $adata = <ASN>;
           close(ASN);
           if ($adata =~ /SUBMIT=0/) {
               $text .= "(seen on $date but not yet submitted)<BR>";
           } else {
               $pr = '*';
               $text .= "(submitted on $date but not yet graded)<BR>";
           }
       } else {
           $text .= "(not seen)<BR>";
       }
       $text = "<B>$asn_name:</B> $pr/$tp $text";
   }

   return ($text,$tp,$pr);
}

1;
