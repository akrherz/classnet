package DIALOG;
use Exporter;
@ISA = (Exporter, ASSIGNMENT);

#########
=head1 DIALOG

=head1 Methods:

=cut
#########

require ASSIGNMENT;

#########################################
=head2 new($query, $cls, $member, $assign_name)

=over 4

=item Description

=item Params

=item Instance Variables

=item Returns
DIALOG object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $assign_name) = @_;
   my $self = ASSIGNMENT->new($query,$cls,$member,$assign_name);
   bless $self, $class;
   $self->{'Editor Type'} = 'DIALOGEDITOR';
   # Make sure this student has a dir reserved for this dialog assignment
   if (($member and ($member->{'Member Type'} eq 'student')) and !(-e $self->{'Dialog Dir'})) {
      mkdir($self->{'Dialog Dir'},0700) or
        ERROR::system_error('DIALOG','create','mkdir',$self->{'Dialog Dir'});
   }
   return $self;
}

#########################################
=head2 create()

=over 4

=item Description
Create a DIALOG assign

=item Params
none

=item Returns
none

=back

=cut

sub create {
    my ($self) = @_;
    ASSIGNMENT->create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('DIALOG.pm','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type>";
    close OPTION;
#    mkdir($self->{'Dialog Dir'},0700) or
#        ERROR::system_error('DIALOG','create','mkdir',$self->{'Dialog Dir'});
}

sub delete {
   my ($self) = @_;
   system "rm -rf $self->{'Dev Root'}";

   #delete student assignments
   my $cls = $self->{'Class'};
   my @stu_names = $cls->get_mem_names(student);
   foreach $stu (@stu_names) {
      my $disk_name = CGI::escape($stu);
      system "rm -f $cls->{'Root Dir'}/students/$disk_name/dialog/$self->{'Disk Name'}";
      system "rm -f $cls->{'Root Dir'}/students/$disk_name/dialog/$self->{'Disk Name'}.cn_bak*";
   }

}

sub upload {
   my ($self,$hfile) = @_;


   $self->create();

   # There should probably be MORE error checking here on the incoming form!!

   # Get rid of any form stuff
   $hfile =~ s/<\s*\/?FORM[^>]*>//ig;
   my @ta_array = split(/(<\/textarea>)/i, $hfile);

   # Give names (CN_1, CN_2...) to all textareas. Overide any user names.
   my $num_ta = 0;
   foreach $elt (@ta_array) {
      if (!($elt =~ /<\/textarea>/i)) {
      	 $num_ta++;
      	 $elt =~ s/(<\s*textarea)\s+name=\S+([^>*])/$1$2/i;      	 
      	 $elt =~ s/(<\s*textarea)/$1 name=CN_$num_ta/i;
      }      	 
   }
   if ($hfile =~ m/href="?^h/i) {
        ERROR::user_error($ERROR::NOTDONE,
      	    "All hrefs must be <b>href=\"http://.....</b>");
        exit(0);
   }
 
   # Just give the assignment file the assignment name
   my $file = "$self->{'Dev Root'}/$self->{'Disk Name'}";
   open(DIALOG_FILE,">$file") or
       ERROR::system_error('Dialog.pm',"upload","open",$self->{'Name'});
   print DIALOG_FILE @ta_array;
   close DIALOG_FILE;
   chmod 0600, $file;
   
   return;
}
sub get_graded_form {
    my $self = shift;
    return "<B>$self->{'Name'}: No correct answers for Dialog assignments</B>"; 
}

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $text = "<B>$asn_name:</B> 0/0<BR>";
   return ($text,0,0);
}

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
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Member'}->{'Ticket'}">
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

sub submit_edit_changes {
   my ($self,$query) = @_;
   $self->submit($query);
   
}
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
   DIALOG->print_dialog_header("Dialog with $self->{'Member'}->{'Username'} ");
   print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/gradebook">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$query->{'Ticket'}->[0]">
<INPUT TYPE=hidden NAME="Student File" VALUE="$self->{'Student File'}">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
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
sub get_new_form {
   ERROR::user_msg("Sorry, cannot add a new DIALOG assignment");
}

sub get_stats {
   ERROR::user_msg("No statistics for Dialog assignments");
}

sub format_stats {
   ERROR::user_msg("No statistics for Dialog assignments");
}

sub format_raw_data {

   my ($self,$sname) = @_;
   undef $/;

   open(ASN,"<$self->{'Dialog Dir'}/$self->{'Disk Name'}");
   my $data = <ASN>;
   close ASN;
   "\n*****$sname ($self->{'Name'}) *****\n$data\n";

}

1;
