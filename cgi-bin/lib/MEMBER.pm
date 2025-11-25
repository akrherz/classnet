package MEMBER;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader);

#########
=head1 MEMBER

=head1 Methods:

=cut
#########

require CGI;
require CN_UTILS;

#########################################
=head2 new($query, $cls, $uname)

=over 4

=item Description
Create a new class member object. If the member
already exists somewhere in the class (including
requesting membership), then all information
about that user is also read from that member's
info file. If this call came from a member 
registering for a class, the member info is
taken from the HTML form.

=item Params
$query: CGI parsed form object. This object may be null
if $uname is present

$cls: Class object

$uname: Unmodified username. overides query username if defined

=item Instance Variables
$self->{'Username'}: Unmodified version of the username. Usernames are
of the form: Last_name, First_name

$self->{'Disk Username'}: Escaped username with beginning and trailing
white space removed

$self->{'First Name'}: The member's first name

$self->{'Last Name'}: The member's last name

$self->{'Password'}: The member's password

$self->{'Root Dir'}: The class root directory 
(e.g. /local1/classnet/class_name)

$self->{'Email Address'}: Member's email address

=item Returns
MEMBER object

=back

=cut

sub new {
   my($class, $query, $cls, $uname) = @_;
   my $self = {};
   bless $self;
   $self->{'Root Dir'} = $cls->{'Root Dir'};
   # I have no idea why, but I have to initialize this up
   # here to avoid Perl errors!!! This will likely have to
   # be done to other self vars eventually...
   $self->{'Username'} = '';
   $self->{'First Name'} = '';
   $self->{'Last Name'} = '';
   $self->{'Disk Username'} = '';
   $self->{'Password'} = '';
   $self->{'Email Address'} = '';

   # Registration?
   if ($query and defined $query->{'First Name'}->[0]) {
       $self->{'Email Address'} = $query->{'Email Address'}->[0];
       $self->{'Password'} = $query->{'Password'}->[0];
       my $fname = $self->{'First Name'} = CN_UTILS::remove_spaces($query->{'First Name'}->[0]);
       my $lname = $self->{'Last Name'} = CN_UTILS::remove_spaces($query->{'Last Name'}->[0]);
       #if ($fname =~ /\W/) {
       #    ERROR::user_error(ERROR::BADNAME,$fname);
       #}
       #if ($lname =~ /\W/) {
       #    ERROR::user_error(ERROR::BADNAME,$lname);
       #}
       # Change to lower case and capitalize first letter
       $fname =~ tr/A-Z/a-z/;
       $fname =~ s/(.)/\u$1/;
       $lname =~ tr/A-Z/a-z/;
       $lname =~ s/(.)/\u$1/;
       $self->{'Username'} = $lname . ", " . $fname;

       # Change to disk version
       my $sep = CGI::escape(", ");
       $fname = CGI::escape($fname);
       $lname = CGI::escape($lname);
       $self->{'Disk Username'} = $lname . $sep . $fname

   }
   # Else this member should exist
   else {
       my $name = ($uname ? $uname : $query->{'Username'}->[0]);
       # Change Username to disk representation;
       my ($last,$first) = split(/, /,$name);
       $self->{'Username'} = $name;
       $self->{'First Name'} = $first;
       $self->{'Last Name'} = $last;
       $self->{'Disk Username'} = CGI::escape($name);
       $self->{'Password'} = '';
       $self->{'Email Address'} = '';
       $self->set_info($cls);
   }
   $self;
}

# Prevent AutoLoader from looking for DESTROY.al
sub DESTROY { }

__END__

#########################################
=head2 check_password($query)

=over 4

=item Description
Check if a valid password was entered into the form

=item Params
$query: CGI parsed form object

=back

=cut

sub check_password {
   my ($self, $query) = @_;
   ($self->{'Password'} eq $query->{'Password'}->[0]) or
       ERROR::user_error($ERROR::PWDBAD);
}

#########################################
=head2 set_info($cls)

=over 4

=item Description
Get information from the class member file and place 
into the receiving member object. The member is 
searched for in the student directory first, followed 
by the instructor directory and finally the requests directory

=item Params
$cls: Class object

=back

=cut

sub set_info {
   my ($self,$cls) = @_;
   my (@mem_list,$line_info);

   # Get the member type
   my $mem_type = $cls->mem_exists($self->{'Disk Username'});
   unless ($mem_type) {
       ERROR::user_error($ERROR::MEMBERNF,$self->{'Username'});
   }

   # Open the file
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$self->{'Disk Username'}";

   $/ = "\n";
   (open(MEM_FILE, "<$fname")) or
       ERROR::system_error("MEMBER","set_info","Open",$self->{'Username'});
   chomp(@mem_list = <MEM_FILE>);
   close(MEM_FILE);
   foreach $line_info (@mem_list) {
       my ($info_name,$info_value) = split(/=/,$line_info);
       $self->{$info_name} = $info_value;
   }
}

#########################################
=head2 print_edit_info_form($cls, $inst)

=over 4

=item Description
Print edit information form

=item Params
$cls: Class object

$inst: Optional instructor object. If exists, it is changing self's data

=back

=cut

sub print_edit_info_form {
   my ($self, $cls, $mem) = @_;

   # Only owners can edit other instructors
   if (($mem->{'Member Type'} =~ /instructor/) and 
       ("$self->{'Username'}" ne "$mem->{'Username'}") and
       !($self->{'Priv'} =~ /owner/ || $self->{'Priv'} =~ /student/)) {
       ERROR::user_error($ERROR::NOPERM);
   }

   $_ = $ENV{'SCRIPT_NAME'};
   SWITCH:  {
       /instructor/    &&
           do  {
                   $back_title = 'Instructor Menu';
                   last SWITCH;
               };

       /membership/    &&
           do  {
                   $back_title = 'Members Menu';
                   last SWITCH;
               };

       /student/    &&
           do  {
                   $back_title = 'Student Menu';
                   last SWITCH;
               };
   }
   CN_UTILS::print_cn_header("Edit Personal Data");
   print <<"FORM";
<CENTER><H3>$mem->{'First Name'} $mem->{'Last Name'}</H3></CENTER>
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT$ENV{'SCRIPT_NAME'}">
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Edit">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<INPUT TYPE=hidden NAME=Mem_Username VALUE="$mem->{'Username'}">
<H3>Email</H3>
Email Address: <INPUT NAME="New Email Address" size=40 VALUE="$mem->{'Email Address'}"><p><br>
<H3>Password</H3>
<PRE>       New Password: <INPUT TYPE=password NAME="New Password">
Verify New Password: <INPUT TYPE=password NAME="Verify New Password"></PRE><p>
FORM

   # Is owner editing another instructor other than herself/himself
   if (($self->{'Priv'} =~ /owner/) and 
       ($self->{'Username'} ne $mem->{'Username'}) and  
       ($mem->{'Member Type'} =~ /instructor/)) {
       my $chk_students = $mem->{'Priv'} =~ /student/ ? "CHECKED" : "";
       my $chk_assigns = $mem->{'Priv'} =~ /assignment/ ? "CHECKED" : "";
       print <<"FORM";
<H3>Privileges</H3>
<INPUT TYPE=checkbox NAME=Privileges VALUE=students $chk_students> Manage students 
<INPUT TYPE=checkbox NAME=Privileges VALUE=assignments $chk_assigns> Manage assignments
FORM
   } elsif ($mem->{'Member Type'} =~ /instructor/) {
     print <<"FORM";
<INPUT TYPE=hidden NAME=Privileges VALUE="$mem->{'Priv'}">
FORM
   }
   print <<"FORM";
<P><CENTER><H4><INPUT TYPE=submit Value=Change> 
<INPUT TYPE=reset Value=Reset>
<BR>
<INPUT TYPE=submit name=memback VALUE="$back_title">
</H4>
</CENTER>
</FORM>
FORM
   CN_UTILS::print_cn_footer("edit_member.html");

}

#########################################
=head2 print_add_member_form($cls)

=over 4

=item Description
Print edit information form

=item Params
$cls: Class object

=back

=cut

sub print_add_member_form {
   my ($self, $cls) = @_;

   # Get the form;
   CN_UTILS::print_cn_header("Add Member");
   print <<"HTML";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Add">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3>
Type: 
<INPUT TYPE=radio NAME=Type VALUE=Student CHECKED> Student 
<INPUT TYPE=radio NAME=Type VALUE=Instructor> Instructor
<HR> 
<H3>Personal Data</H3>
</CENTER>
<PRE>
First Name <INPUT NAME="Member First Name" TYPE="text" SIZE="20">        Last Name  <INPUT
NAME="Member Last Name" TYPE="text" SIZE="20">
Password   <INPUT TYPE="password" NAME="Member Password" SIZE="20">  Verify Password  <INPUT TYPE="password" NAME="Verify Member Password" SIZE="20">
Email      <INPUT NAME="Member Email Address" TYPE="text" SIZE="37">  
</PRE>
<HR>
<CENTER>
<H3>Instructor Privileges</H3>
<INPUT TYPE=checkbox NAME=Privileges VALUE=students> Manage students
<INPUT TYPE=checkbox NAME=Privileges VALUE=assignments> Manage assignments
<HR>
<H4>
<INPUT TYPE=submit Value=Add> <INPUT TYPE=reset> 
<INPUT TYPE=submit name=back VALUE="Members Menu">
</H4>
</CENTER>
HTML
   CN_UTILS::print_cn_footer("add_member.html");
}

#########################################
=head2 print_upload_form($cls)

=over 4

=item Description
Reads in a file of student information and registers them

=item Params
$cls: Class object

=back

=cut

sub print_upload_form {
   my ($self, $cls) = @_;

   # Must be owner
   if (!($self->{'Priv'} =~ /students/ || $self->{'Priv'} =~ /owner/)) {
      &ERROR::user_error($ERROR::NOPERM);
   }

   # Get the form;
   CN_UTILS::print_cn_header("Upload");
   print <<"HTML";
<FORM ENCTYPE="multipart/form-data" METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Upload">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3></CENTER>
<CENTER><img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif"></CENTER>
The <B>Upload</B> option enrolls or deletes students by reading
a file which contains the enrollment information.
(See Help for details.)
<HR>
Enter the local filename or URL below then click on Upload:
<P>
<PRE>
<B>Remote URL:</B> <INPUT NAME=urlname TYPE=text SIZE=40>
<B>Local File:</B> <INPUT NAME=filename TYPE=file SIZE=40>
</PRE>
<CENTER>
<H4>
<INPUT TYPE=submit Value=Upload> <INPUT TYPE=reset> 
<INPUT TYPE=submit name=back VALUE="Members Menu">
</H4>
</CENTER>
HTML
   CN_UTILS::print_cn_footer("upload_members.html");
}

#########################################
=head2 change_info_file($query)

=over 4

=item Description
Change member information

=item Params
$query: CGI parsed form object

=back

=cut

sub change_info_file {

   my ($self, $query) = @_;

   # Verify passwords in the form -- if needed
   $newpwd = $query->param('New Password'); 
   if ($newpwd) {
      if ($newpwd ne $query->param('Verify New Password')) {
       	 &ERROR::user_error($ERROR::PWDVERIFY);
      }
      if ($newpwd ne $self->{'Password'}) {
         $self->{'Password'} = $newpwd;  
      }
   }    

   # Look for email; If blanked out, then do not change
   ($query->param('New Email Address')) and
       $self->{'Email Address'} = $query->param('New Email Address');

   # What about privileges?
   
   if (($self->{'Priv'} =~ /owner/) or ($self->{'Member Type'} eq 'student')) {
       $priv_str = $self->{'Priv'};
   } else {
       $priv_str = join(',',$query->param('Privileges'));
   }
   my $new_fname = "$self->{'Root Dir'}/admin/members/$self->{'Member Type'}s/$self->{'Disk Username'}.new";
   my $fname = "$self->{'Root Dir'}/admin/members/$self->{'Member Type'}s/$self->{'Disk Username'}";

   open(MEM_FILE, ">$new_fname") or 
     &ERROR::system_error("MEMBER","change_info_file","Open",$new_fname);
   print MEM_FILE "Password=$self->{'Password'}\n";
   print MEM_FILE "Email Address=$self->{'Email Address'}\n";
   print MEM_FILE "Priv=$priv_str\n" 
      if ($self->{'Member Type'} eq 'instructor');
   close(MEM_FILE) or
     &ERROR::system_error("MEMBER","change_info_file","Close",$new_fname);
   rename($new_fname, $fname);
   chmod(0600, $fname);
   my $fname = "$self->{'Root Dir'}/admin/elist";
   unlink $fname;
}

#########################################
=head2 print_email_form($cls)

=over 4

=item Description
Print email form

=item Params
$cls: Class object

=back

=cut

sub print_email_form {
   my ($self, $cls) = @_;
   my (@students, @instructors);

   my $hasTable = CN_UTILS::hasTables();
   # Get list of students (Student list may not actually exist)
   if (open(STUDENTS,"<$GLOBALS::CLASSNET_ROOT_DIR/$cls->{'Disk Name'}/admin/member_lists/students")) {
       @students = <STUDENTS>;
       close(STUDENTS);
   }

   # Get list of instructors
   my $inst_fname = "$GLOBALS::CLASSNET_ROOT_DIR/$cls->{'Disk Name'}/admin/member_lists/instructors";
   open(INSTRUCTORS,"<$inst_fname") or
       &ERROR::system_error("Instructor","membership","open",$inst_fname);
   @instructors = <INSTRUCTORS>;
   close(INSTRUCTORS);

   $back_title = ($ENV{'SCRIPT_NAME'} =~ /instructor/)?
       'Instructor Menu':'Student Menu';

   # Print the form
   
   CN_UTILS::print_cn_header("Send Mail");
   print <<"FORM";   
<FORM METHOD=POST ACTION="$GLOBALS::SERVER_ROOT$ENV{'SCRIPT_NAME'}">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<INPUT TYPE=hidden NAME=cn_option VALUE="Send Email">
<CENTER><H3>$cls->{'Name'}</H3></CENTER>
<b>From:</b> $self->{'First Name'} $self->{'Last Name'}($self->{'Email Address'})<BR>
<b>To:</B> (Select Names or click on All)<B>
<CENTER>
FORM
   if ($hasTable) {
       print "<TABLE border=0 width=50%>";
       print "<TH ALIGN=CENTER><B>Students</B>\n";
       print "<TH ALIGN=CENTER><B>Instructors</B>\n";
       print "<TR><TD ALIGN=CENTER>\n";
       print qq|<SELECT MULTIPLE NAME="Students" SIZE=5>|;
       foreach $member (sort @students) {
           print qq|<OPTION> $member\n|;
       }
       print "</SELECT>\n";
       print "<TD ALIGN=CENTER>\n";
       print "<SELECT MULTIPLE NAME=\"Instructors\" SIZE=5>";       	       
       foreach $member (sort @instructors) {
           print qq|<OPTION> $member\n|;
       }
       print "</SELECT><TR>\n";
       print "<TD ALIGN=CENTER><INPUT TYPE=checkbox NAME=\"All Students\"> All\n";
       print "<TD ALIGN=CENTER><INPUT TYPE=checkbox NAME=\"All Instructors\"> All\n";
       print "</TABLE>\n";
   } else {
       print "Students<BR>";
       print qq|<SELECT MULTIPLE NAME="Students" SIZE=5>|;
       foreach $member (sort @students) {
           print qq|<OPTION> $member\n|;
       }
       print "</SELECT><BR>";
       print "<INPUT TYPE=checkbox VALUE=All NAME=\"All Students\"> All<P>";
       print "Instructors<BR>";
       print "<SELECT MULTIPLE NAME=\"Instructors\" SIZE=5>";       	       
       foreach $member (sort @instructors) {
           print qq|<OPTION> $member\n|;
       }
       print "</SELECT><BR>\n";
       print "<INPUT TYPE=checkbox VALUE=All NAME=\"All Instructors\"> All\n";
   }
   print <<"FORM";
</CENTER>
<P>
<b>Subject:</b> <INPUT NAME=Subject SIZE=40></H4>
<CENTER>
<TEXTAREA NAME=Message ROWS=15 COLS=70 WRAP=PHYSICAL></TEXTAREA>
<H4><INPUT TYPE=submit NAME=submit VALUE=Send> <INPUT TYPE=reset>
<BR><INPUT TYPE=submit NAME=memback VALUE="$back_title"></H4>
</CENTER>
FORM
   CN_UTILS::print_cn_footer("email.html");
}

#########################################
=head2 send_email($query, $cls)

=over 4

=item Description
Send email

=item Params

=back

=cut

sub send_email {
   my ($self, $query, $cls) = @_;
   my @mem_names;
   my $email_recips = "";    	       
   my $SENDMAIL = '/usr/sbin/sendmail';
   my @mem_names = $query->param('All Students') ?
       $cls->get_mem_names('student'):$query->param('Students');
   push (@mem_names, $query->param('All Instructors')?
       $cls->get_mem_names('instructor'):$query->param('Instructors'));

   $n = @mem_names;
   if ($n == 0) {
       ERROR::user_error($ERROR::NOTDONE,"mail message because you didn't select any recipients. Click <B>Back</b> and try again");
   }
   # Get in the email addresses of all members into one string
   my $i = 0;
   my $email_recips = '';    	       
   foreach $mem_name (@mem_names) {
       %mem_info = $cls->get_mem_info($mem_name);
       my $recip_info = ", $mem_info{'Email Address'} ($mem_info{'First Name'} $mem_info{'Last Name'})";
       $email_recips =~ s/$/$recip_info/;
       $i++;
       if (($i % 50) == 0 || $i == $n) {
           open (MAIL, "| $SENDMAIL -t -n -oi $mem_info{'Email Address'}") ||
       	       ERROR::system_error("MEMBER.pm", "send_email", "Open Mail", 
       	           	       	       "From: $self->{'Username'}", "To: $mem_info{'Email Address'}");
           print MAIL "Reply-to: $self->{'Email Address'} ($self->{'First Name'} $self->{'Last Name'})\n";
           print MAIL "From: $self->{'Email Address'} ($self->{'First Name'} $self->{'Last Name'})\n";
           print MAIL "Bcc: $email_recips\n";
           print MAIL "Errors-to: $self->{'Email Address'}\n";
           print MAIL "Subject: $query->{'Subject'}->[0]\n";
           print MAIL "$query->{'Message'}->[0]\n\n";
           close (MAIL);
           $email_recips = '';
        }
   }
   $self->print_menu($cls);
   exit(0);
}

sub chat {
    my ($self,$cls) = @_;
    my $cname = CGI::escape($cls->{'Name'});
    my $ticket = CGI::escape($self->{'Ticket'});
    # call the assignments script to process command
    my $url .= "&Class+Name=$cname";
    $url .= "&Ticket=$ticket";

    print <<"HTML";
Content-type: text/html

<HTML>
<HEAD>
  <TITLE>$class Chat</TITLE>
</HEAD>
<frameset rows="3*,*">
  <frame name=comment src="chat?chat_option=Comment$url">
  <frame name=entry src="chat?chat_option=Entry$url">
<noframes>
<BODY>
  Sorry! This document cannot be viewed without a frames-capable
  browser.
</BODY>
</noframes>
</frameset>
</HTML>
HTML
}

1;










