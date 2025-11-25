package JAVA;
use Exporter;
@ISA = (Exporter, ASSIGNMENT);

#########
=head1 JAVA

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
JAVA object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $assign_name) = @_;
   my $self = ASSIGNMENT->new($query,$cls,$member,$assign_name);
   bless $self, $class;
   $self->{'Editor Type'} = 'JAVAEDITOR';
   # Make sure this student has a dir reserved for this java assignment
   if (($member and ($member->{'Member Type'} eq 'student')) and !(-e $self->{'Java Dir'})) {
      my $javadir = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}/java"; 
      if (!(-e $javadir)) {
          mkdir($javadir,0700) or
              ERROR::system_error('JAVA','create','mkdir',$javadir);
      }
      mkdir($self->{'Java Dir'},0700) or
        ERROR::system_error('JAVA','create','mkdir',$self->{'Java Dir'});
   }
   return $self;
}

#########################################
=head2 create()

=over 4

=item Description
Create a JAVA assign

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
        ERROR::system_error('JAVA.pm','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type>";
    close OPTION;
#    mkdir($self->{'Java Dir'},0700) or
#        ERROR::system_error('JAVA','create','mkdir',$self->{'Java Dir'});
}

sub delete {
   my ($self) = @_;
   system "rm -rf $self->{'Dev Root'}";

   #delete student assignments
   my $cls = $self->{'Class'};
   my @stu_names = $cls->get_mem_names(student);
   foreach $stu (@stu_names) {
      my $disk_name = CGI::escape($stu);
      system "rm -rf $cls->{'Root Dir'}/students/$disk_name/java/$self->{'Disk Name'}";
   }

}

sub upload {
   my ($self,$hfile) = @_;

   if ( !(-e $self->{'Dev Root'}) ) {
      $self->create();
   }

   # Name of file is last
   my @toks = split('/',$url);
   my $file = "$self->{'Dev Root'}/$toks[$#toks]";
   open(JAVA_FILE,">$file") or
       ERROR::system_error('Java.pm',"upload","open",$file);
   print JAVA_FILE $hfile;
   close JAVA_FILE;
   chmod 0600, $file;
   
   return;
}
sub get_graded_form {
    my $self = shift;
  
    # This needs to be generalized... Lesson Graph students can replay
    #!($self->{'Name'} =~ /Graph/) and
    #	return "<B>$self->{'Name'}: No correct answers for Java  assignments</B>"; 

   # Read in the html file
   open(HTML_FILE, "<$self->{'Dev Root'}/$self->{'Disk Name'}.html") or
      ERROR::system_error("JAVA.pm","send_edit_form","open","Could not open $self->{'Name'}.html"); 
   undef $/;
   my $java_file = <HTML_FILE>;
   close HTML_FILE;

   # Find the date
   my @months = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
   # handle year2000 problem
   if ($year < 100) {
      $year += ($year < 96)? 2000:1900;
   }
   my $date = sprintf("%02d$months[$mon]%04d",$mday,$year);

   # Get a list of protocol files and message files
   my @asnfiles;
   my @msgfiles;
   my @protfiles;
   opendir(JAVADIR,$self->{'Java Dir'});
   push(@asnfiles,grep(!/^\.\.?/,readdir(JAVADIR)));
   closedir(JAVADIR);
   @msgfiles = grep(/^From_/,@asnfiles);
   @protfiles = grep(!/^From_/,@asnfiles);
   my $protlist = join(';',@protfiles);
   my $msglist = join(';',@msgfiles);

   # Modify the applet params
   # SRM_ALIAS must be defined in srm.conf of ClassNet's httpd server
   #    - this allows server document retrieval in other directories
   # BASE HREF must be added to the document
   # All % signs for codebase must be converted to hex rep. of %25
   #my $code_base = "$GLOBALS::SRM_ALIAS\/$self->{'Class'}->{'Disk Name'}\/assignments\/$self->{'Disk Name'}";
   my $code_base = "$GLOBALS::SRM_ALIAS";
   $code_base =~ s/%/%25/g;
   $java_file =~ s/<APPLET/<APPLET/i;
   my $param_str =<<"PARAMS";
<param name="memberType" value="teacher">
<param name="filePath" value="$self->{'Java Dir'}">
<param name="fileList" value="$protlist">
<param name="date" value="$date">
<param name="cn_option" value="Answers">
<param name="msgNames" value="$msglist">
PARAMS
   $java_file =~ s/<\/APPLET>/$param_str<\/APPLET>/i;

   print "Content-type: text/html\n\n";
   print $java_file;
   exit(0);
}

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $text = "<B>$asn_name:</B> 0/0<BR>";
   return ($text,0,0);
}

sub send_ungraded_form {
   my $self = shift;

   my $html_file = "$self->{'Dev Root'}/$self->{'Disk Name'}.html";
   # the student protocol file name is based on today's date and time
   my @months = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
   # handle year2000 problem
   if ($year < 100) {
      $year += ($year < 96)? 2000:1900;
   }
   my $fname = sprintf("%02d$months[$mon]%04d_%02d_%02d",$mday,$year,$hour,$min);
   my $date = sprintf("%02d$months[$mon]%04d",$mday,$year);

   open(HTML_FILE, "<$html_file") or
      ERROR::system_error("JAVA.pm","send_ungraded_form","open","Could not open $self->{'Name'}.html"); 

   # Read in the html file
   undef $/;
   my $java_file = <HTML_FILE>;
   close HTML_FILE;

   # Get a list of message files
   my @msgfiles;
   opendir(JAVADIR,$self->{'Java Dir'});
   push(@msgfiles,grep(/^From_/,readdir(JAVADIR)));
   #if ($self->{'Member Type'} eq 'student')
   #   push(@msgfiles,grep(/^From_t/,readdir(JAVADIR)));
   #else
   #   push(@msgfiles,grep(/^From_s/,readdir(JAVADIR)));
   closedir(JAVADIR);
   my $msgList = join(';',@msgfiles);
   
   # Modify the applet params
   # SRM_ALIAS must be defined in srm.conf of ClassNet's httpd server
   #    - this allows server document retrieval in other directories
   # BASE HREF must be added to the document
   # All % signs for codebase must be converted to hex rep. of %25
   my $code_base = "$GLOBALS::SRM_ALIAS";
   $code_base =~ s/%/%25/g;
   $java_file =~ s/<APPLET/<APPLET/i;
   my $param_str =<<"PARAMS";
<param name="memberType" value="student">
<param name="filePath" value="$self->{'Java Dir'}">
<param name="date" value="$date">
<param name="fileName" value="$fname">
<param name="msgNames" value="$msgList">
PARAMS
   $java_file =~ s/<\/APPLET>/$param_str<\/APPLET>/i;

   print "Content-type: text/html\n\n";
   print $java_file;
}

sub send_edit_form {
   my ($self,$query,$stu) = @_;
   my @students = @{$stu};
   my $nstu = @students;
   if ($nstu != 1) {
      ERROR::print_error_header('Edit?');
      print "Please select only one student for Java Assignments. ($nstu students selected)";
      CN_UTILS::print_cn_footer();
      exit(0);
   }
   # NOTE: Based on CLASS send_edit_form, it is assumed that this current asn object is
   # the targeted student!

   # Read in the html file
   open(HTML_FILE, "<$self->{'Dev Root'}/$self->{'Disk Name'}.html") or
      ERROR::system_error("JAVA.pm","send_edit_form","open","Could not open $self->{'Name'}.html"); 
   undef $/;
   my $java_file = <HTML_FILE>;
   close HTML_FILE;

   # Find the date
   my @months = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
   # handle year2000 problem
   if ($year < 100) {
      $year += ($year < 96)? 2000:1900;
   }
   my $date = sprintf("%02d$months[$mon]%04d",$mday,$year);

   # Get a list of protocol files and message files
   my @asnfiles;
   my @msgfiles;
   my @protfiles;
   opendir(JAVADIR,$self->{'Java Dir'});
   push(@asnfiles,grep(!/^\.\.?/,readdir(JAVADIR)));
   closedir(JAVADIR);
   @msgfiles = grep(/^From_/,@asnfiles);
   @protfiles = grep(!/^From_/,@asnfiles);
   my $protlist = join(';',@protfiles);
   my $msglist = join(';',@msgfiles);

   # Modify the applet params
   # SRM_ALIAS must be defined in srm.conf of ClassNet's httpd server
   #    - this allows server document retrieval in other directories
   # BASE HREF must be added to the document
   # All % signs for codebase must be converted to hex rep. of %25
   my $code_base = "$GLOBALS::SRM_ALIAS";
   $code_base =~ s/%/%25/g;
   $java_file =~ s/<APPLET/<APPLET/i;
   my $param_str =<<"PARAMS";
<param name="memberType" value="teacher">
<param name="filePath" value="$self->{'Java Dir'}">
<param name="fileList" value="$protlist">
<param name="cn_option" value="Answers">
<param name="date" value="$date">
<param name="msgNames" value="$msglist">
PARAMS
   $java_file =~ s/<\/APPLET>/$param_str<\/APPLET>/i;

   print "Content-type: text/html\n\n";
   print $java_file;
}

sub get_new_form {
   ERROR::user_msg("Sorry, cannot add a new JAVA assignment");
}

sub get_stats {
   ERROR::user_msg("No statistics for Java assignments");
}

sub format_stats {
   ERROR::user_msg("No statistics for Java assignments");
}

sub format_raw_data {

   my ($self,$sname) = @_;
   my @asnfiles;
   opendir(JAVADIR,$self->{'Java Dir'});
   push(@asnfiles,grep(!/^\.\.?/,readdir(JAVADIR)));
   closedir(JAVADIR);

   undef $/;
   foreach $asn_name (sort {uc($a) cmp uc($b)} @asnfiles) {
      open(ASN,"<$self->{'Java Dir'}/$asn_name");
      my $data = <ASN>;
      $body .= "*****$sname ($asn_name) *****\n$data\n";
   }
   return $body;
}

1;
