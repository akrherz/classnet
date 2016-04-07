# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

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
   my $code_base = "$GLOBALS::SRM_ALIAS\/$self->{'Class'}->{'Disk Name'}\/assignments\/$self->{'Disk Name'}";
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

1;
