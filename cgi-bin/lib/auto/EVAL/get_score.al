# NOTE: Derived from lib/EVAL.pm.  Changes made here will be lost.
package EVAL;

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $escaped_asn_name = CGI::escape($asn_name);
   my $escaped_stud_name = CGI::escape($stud_name);
   my $text;

   # Set input record separator and read the file
   $/ = "\n";

   # Set input record separator and read the file
   my $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/graded/$escaped_asn_name";
   my $pr = '-';
   if (-e $path) {
       open(ASN,"<$path") or
           ERROR::system_error("EVAL","get_score","open",$path);
       flock(ASN,$LOCK_EX);
       my $test_header = <ASN>;
       flock(ASN,$LOCK_UN);
       close(ASN);
       my %scores = TEST::unpack_stud_test_header($test_header);
       (%scores) or
            ERROR::system_error('EVAL','get_score','unpack stheader',
                                "$path:$test_header");
       $tp = 0;
       $scores{'SUBMIT'} = 1;
       $pr = '#';
       $text = "<B>$asn_name:</B> non-scored evaluation or survey";
       my $seen = $scores{'SEEN'};
       if (defined $seen) {
          $text .= "<BR>First Seen on $seen";
       }
       my $subdate = $scores{'SUBDATE'};
       if (defined $subdate) {
          $text .= "<BR>Submitted on $subdate";
       }
       my $date = CN_UTILS::getTime($path);
       $text .= "<BR>Graded on $date<BR>";
       return ($text,$tp,$pr);
    } else {
       $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/ungraded/$escaped_asn_name";
       $text = "<B>$asn_name:</B> ";
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
       return ($text,$1,$pr);
    }
}

1;
