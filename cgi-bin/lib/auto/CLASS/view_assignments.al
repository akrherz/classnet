# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub view_assignments {
   my ($self,$stud_names,$asn_names,$inst,$op) = @_;
   my $tot_pts_rec = 0;
   my $tot_pts = 0;
   my @asn_files;
   my %asn_type;

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   TEST->print_test_header("\u$op Assignments");
   print <<"HEAD";
<CENTER><H4>$self->{'Name'}</H4>$GLOBALS::HR
</CENTER>
Select assignments to $op:<BR>
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/gradebook>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit \u$op Changes">
HEAD
   #  
   foreach $sname (@{$stud_names}) {
       print "<B>$sname</B><BR>\n";
       my $stud = $self->get_member("",$sname);
       foreach $aname (@{$asn_names}) {
           my $asn = $self->get_assignment("",$stud,$aname);
           my @alist = $asn->get_names($op eq 'add'?'nonexisting':'existing');
           foreach (@alist) {
               my $name = CGI::escape($_);
               my $tp = ref($asn);
               my $val = "$sname/$tp/$name";
               print "<INPUT TYPE=checkbox NAME=assignments VALUE=\"$val\"> $_<BR>\n";
           }
       }
       print "<P>\n";
   }
   print <<"FOOT";
<CENTER><H4>
<INPUT TYPE=submit NAME=submit Value="\u$op">
<INPUT TYPE=reset>
<BR>
<INPUT TYPE=submit NAME=gradeback VALUE="Gradebook Menu">
</H4></CENTER>
</FORM>
$GLOBALS::HR
</BODY>
</HTML>
FOOT
   exit(0);
}

1;
