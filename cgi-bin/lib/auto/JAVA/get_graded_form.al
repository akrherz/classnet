# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

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
   my $code_base = "$GLOBALS::SRM_ALIAS\/$self->{'Class'}->{'Disk Name'}\/assignments\/$self->{'Disk Name'}";
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

1;
