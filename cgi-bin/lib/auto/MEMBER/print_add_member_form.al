# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

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

1;
