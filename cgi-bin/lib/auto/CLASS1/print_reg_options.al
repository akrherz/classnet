# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub print_reg_options {
    my ($self,$inst) = @_;
    
    my @ck = (undef,undef,undef);
    $ck[$self->{'Verify Enrollment'}] = 'CHECKED';
    my $expire = $self->{'Expiration Month'};
    CN_UTILS::print_cn_header("Class Options");
    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/instructor>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME=cn_option VALUE="Change Class">
<CENTER><H3>$self->{'Name'}</H3>
Expiration Date <SELECT NAME="Expiration Month">
FORM

@monname = ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');
$mon = (localtime)[4] + 1;
$year = (localtime)[5] + 1900;
for ($i= 0; $i < 12; $i++, $mon++) {
  if ($mon == 12) {
    $mon = 0; $year++;
  }
  my $date = "$monname[$mon] $year";
  if ($expire eq $date) {
    print "<OPTION SELECTED>$date\n";
  } else {  
    print "<OPTION>$date\n";
  }
}

print <<"END_FORM";
</SELECT> 
<P>
Enrollment: <INPUT TYPE=radio NAME='Verify Enrollment' VALUE=0 $ck[0]> Open 
<INPUT TYPE=radio NAME='Verify Enrollment' VALUE=1 $ck[1]> Approval
<INPUT TYPE=radio NAME='Verify Enrollment' VALUE=2 $ck[2]> Closed 
<h3>For Registered Iowa State University Classes only</h3>
</center>
<p>
<INPUT TYPE=check NAME='Enable update'>Enable automatic updating of class list<br>
Official ISU Class Name (Example: F2001-ME215-A):<INPUT TYPE=text VALUE="F2001-" col=20><br>
Your ISU Card Number (9 digits):<INPUT TYPE=text VALUE="000000000" col=9><br>
<br>
<center>
<h3>Class List Options</h3>
</center>
<INPUT TYPE=check NAME='Init'>Process only initial adds<br>
<INPUT TYPE=check NAME='Add'>Process adds<br>
<INPUT TYPE=check NAME='Drop'>Process drops<br>
<CENTER>
<P>
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save> 
<INPUT TYPE=reset> 
<BR>
<INPUT TYPE=submit NAME=memback VALUE="Instructor Menu">
</H4>
</CENTER>
END_FORM
    CN_UTILS::print_cn_footer("class_options.html");
}

1;
