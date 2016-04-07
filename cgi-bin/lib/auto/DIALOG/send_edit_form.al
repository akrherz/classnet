# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub send_edit_form {
   my ($self,$query,$stu) = @_;
   my @students = @{$stu};
   my $nstu = @students;
   if ($nstu != 1) {
      ERROR::print_error_header('Edit?');
      print "Please select only one student for Dialog Assignments. ($nstu students selected)";
      CN_UTILS::print_cn_footer();
      exit(0);
   }
   # NOTE: Based on CLASS send_edit_form, it is assumed that this current asn object is
   # the targeted student!
   # $self->send_ungraded_form();

   my $html_file = "$self->{'Dev Root'}/$self->{'Disk Name'}";
   open(HTML_FILE, "<$html_file") or
      ERROR::system_error("DIALOG.pm","send_ungraded_form","open","Could not open $html_file"); 

   # Read in the html file
   undef $/;
   my $dialog_file = <HTML_FILE>;
   close HTML_FILE;
   my @dialog_array = split(/(<\/textarea>)/i, $dialog_file);

   # Create student file if student hasn't yet created it
   my $stud_file = "$self->{'Dialog Dir'}/$self->{'Disk Name'}";
   if (!(-e $stud_file)) {
      open(STUD_FILE, ">$stud_file") or
      	 ERROR::system_error("DIALOG.pm","send_ungraded_form","open","Could not open $stud_file");
      my $name; 
      # Save backups: These are created each time instructor submits
      # Reason: Someone could delete part or all of the conversation from
      # the text area boxes. This may be undesirable.
      # start with backup number 1 and go through 4 -- 4 is arbitrary
      print STUD_FILE "<CN_BAK_NUM=1>\n";
      foreach $elt (@dialog_array) {
      	 if ($elt =~ /<\/textarea/i) {
      	    print STUD_FILE "<CN_Q NAME=$name>\n";
      	 }
      	 else {
      	    $elt =~ m/<\s*textarea\s*name="?([^\s">]+)/i;
      	    $name = $1;
      	 }
      }
      close STUD_FILE;
      chmod 0600, $stud_file;
   }

   # Read in student file
   open(STUD_FILE, "<$stud_file") or
      ERROR::system_error("DIALOG.pm","send_ungraded_form","open","Could not open $stud_file"); 
   my $dialog_file = <STUD_FILE>;
   close STUD_FILE;
   my @stud_array = split(/<CN_Q NAME=[^>]*>\n/i, $dialog_file);

   # Leave the date/time reply stuff out for now
   # Find the date and time
   #my @months = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);
   #($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
   # handle year2000 problem
   #if ($year < 100) {
   #   $year += ($year < 96)? 2000:1900;
   #}
   #my $date_time = sprintf("%02d$months[$mon]%04d_%02d_%02d",$mday,$year,$hour,$min);

   #Send the file
   DIALOG::print_dialog_header("Dialog with $self->{'Member'}->{'Username'} ");
   print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/gradebook">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME=Username VALUE="$query->{'Username'}->[0]">
<INPUT TYPE=hidden NAME="Student File" VALUE="$self->{'Student File'}">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
<INPUT TYPE=hidden NAME=Password VALUE="$query->{'Password'}->[0]">
FORM

   my $cnt=1;
   foreach $elt (@dialog_array) {
      if ($elt =~ /<\/textarea/i) {
      	 print $stud_array[$cnt];
      	 $cnt++;
      }
      print $elt;
   }
   # Finish the form
   print "<H4><CENTER><INPUT TYPE=submit VALUE=\"Submit Dialog\"></CENTER></H4></FORM>\n";
   CN_UTILS::print_cn_footer();
   exit(0);

}

1;
