# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub send_ungraded_form {
   my $self = shift;
   my $html_file = "$self->{'Dev Root'}/$self->{'Disk Name'}";
   open(HTML_FILE, "<$html_file") or
      ERROR::system_error("DIALOG.pm","send_ungraded_form","open","Could not open $html_file"); 

   # Read in the html file
   undef $/;
   my $dialog_file = <HTML_FILE>;
   close HTML_FILE;
   my @dialog_array = split(/(<\/textarea>)/i, $dialog_file);

   # Create student file if this is first time
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
   DIALOG->print_dialog_header("$self->{'Name'} dialog");
   print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/assignments">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit DIALOG">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME=Username VALUE="$self->{'Member'}->{'Username'}">
<INPUT TYPE=hidden NAME=Password VALUE="$self->{'Member'}->{'Password'}">
FORM

   my $cnt=1;
   foreach $elt (@dialog_array) {
      if ($elt =~ /<\/textarea/i) {
      	 print $stud_array[$cnt];
      	 $cnt++;
      }
      print $elt;
   }
   print"<p><CENTER><H4><INPUT TYPE=submit Value=Submit><INPUT TYPE=reset></H4><p></CENTER>\n</FORM>";
}

1;
