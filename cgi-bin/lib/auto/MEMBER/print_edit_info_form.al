# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

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

1;
