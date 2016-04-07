# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub submit {
   my ($self,$query) = @_;
   my $inst_submission = 0;

   if (defined $query) {
      $inst_submission = 1;
   }
   else {
      $query = $self->{'Query'};
   }

   # Read the student file and fill in new answers
   my $stud_file = "$self->{'Dialog Dir'}/$self->{'Disk Name'}";

   undef $/; 
   open(STUD_FILE, "<$stud_file") or
      ERROR::system_error("DIALOG.pm","send_ungraded_form","open","Could not open $stud_file");
   my $dialog_file = <STUD_FILE>;
   close STUD_FILE;
   my @stud_array = split(/(<CN_Q NAME=[^>]*>\n)/i, $dialog_file);

   my $bak_file;
   # Keep 4 (aribitary #) backup files of conversations after instructor submits
   if ($inst_submission == 1) {
      $stud_array[0] =~ /<CN_BAK_NUM=(\d)>/i;
      my $bak_num = $1;
      $bak_file = "$self->{'Dialog Dir'}/$self->{'Disk Name'}.cn_bak$bak_num";
      (++$bak_num == 5) and
      	 $bak_num = 1;
      $stud_array[0] = "<CN_BAK_NUM=$bak_num>\n";
   }

   my $name = "";
   open(STUD_FILE, ">$stud_file") or
      ERROR::system_error("DIALOG.pm","send_ungraded_form","open","Could not open $stud_file");
 
   print STUD_FILE $stud_array[0];
   foreach $elt (@stud_array) {
      ($elt =~ /<CN_Q NAME=([^>]*)>\n/i) and
      	 print STUD_FILE $elt, $query->{$1}->[0];
   }
   close STUD_FILE;
   
   # Save what teacher sent?
   if ($inst_submission == 1) {
      system "cp $stud_file $bak_file";
      chmod 0600, $bak_file;
   }

}

1;
