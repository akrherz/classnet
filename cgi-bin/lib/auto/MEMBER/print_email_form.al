# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

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

1;
