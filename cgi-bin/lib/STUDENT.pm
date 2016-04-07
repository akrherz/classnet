package STUDENT;
@ISA = qw( MEMBER );

#########################################
=head1 STUDENT

Parent: MEMBER

=head1 Methods:

=cut
#########################################

#use SelfLoader;
require MEMBER;
require ASSIGNMENT;

#########################################
=head2 new($query, $cls, $uname)

=over 4

=item Description
Create a new STUDENT object (type of class member)

=item Params
$query: CGI parsed form object. This object may be null
if $uname is present

$cls: Class object

$uname: Unmodified username. B<OVERIDDEN> by $query->{'Username'} if $query
is defined.

=item Returns
STUDENT object

=back

=cut

sub new {
   my($class, $query, $cls, $uname) = @_;
   my $self = MEMBER->new($query, $cls, $uname);
   $self->{'Member Type'} = 'student';
   bless $self;
}

#__DATA__

#########################################
=head2 add($cls)

=over 4
=item Description
Either add student directly to the class or to a request list

=item Params
$cls: Class object representing class to which the student
is to be added.

=back

=cut

sub add {
   my ($self, $cls) = @_;

   # Must have unique usernames
   if ($cls->mem_exists($self->{'Disk Username'})) {
       ERROR::user_error($ERROR::MEMBEREX,$self->{'Username'});
   }

   #if ($cls->get_uname($self->{'Email Address'})) {
   #    ERROR::user_error($ERROR::EMAILEX,$self->{'Email Address'});
   #}

   if ($cls->{'Verify Enrollment'} == 2) {
     ERROR::user_error($ERROR::CLOSED);
   }
   # Either automatically enroll in class or place on request list
   if ($cls->{'Verify Enrollment'} == 1) {
       chdir("$self->{'Root Dir'}/admin/members/requests");
   }
   else {
       chdir("$self->{'Root Dir'}/admin/members/students");
   }

   open(STUD_FILE, ">$self->{'Disk Username'}") or 
       ERROR::system_error("STUDENT","add","Open",$self->{'Disk Username'});
   print STUD_FILE "Password=$self->{'Password'}\n";
   print STUD_FILE "Email Address=$self->{'Email Address'}\n";
   close(STUD_FILE) or
       ERROR::system_error("STUDENT","add","Close",$self->{'Disk Username'});    
   chmod(0600, $self->{'Disk Username'});

   # Create student assignment directories if necessary
   if ($cls->{'Verify Enrollment'} == 1) {
       my @mem_list = $cls->get_mem_names('requests');
       my $n = @mem_list;
       if ($n == 1) {
           @mem_list = $cls->get_mem_names('instructor');
           foreach $inst (@mem_list) {
               my %info = $cls->get_mem_info($inst);
               if (($info{'Priv'} =~ /students/) or ($info{'Priv'} =~ /owner/)) {
                   CN_UTILS::mail($info{'Email Address'},
                      'Username approvals requested',
                      "One or more students have requested to enroll in class $cls->{'Name'}.
To approve, login to ClassNet and click the Approve button on the 
Instructor/Members menu.");
               }
           }
       }
   } else {
      $cls->create_stud_dirs($self->{'Disk Username'}); 
      $cls->add_to_mem_list('student',$self->{'Username'});
   }
}

#########################################
=head2 exists()

=over 4

=item Description
Does this student already exist in either the class or
on the requesting enrollment list?

=item Returns
'students', 'requests', or ""

=back

=cut

sub exists {

   my $self = shift;
   my $fname = "$self->{'Root Dir'}/admin/members/students/" . $self->{'Username'};
   return 'students' if (-e $fname);

   my $fname = "$self->{'Root Dir'}/admin/requests/" . $self->{'Username'};
   return 'requests' if (-e $fname);

   return "";
}

#########################################
=head2 print_menu($cls)

=over 4

=item Description
Print the student menu

=item Params
$cls: Class Object
=item Returns

=back

=cut

sub print_menu {
    my ($self,$cls) = @_;
    my $msg = $cls->last_access();
    CN_UTILS::print_cn_header("Student Menu");
    print <<"FORM";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/student>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<H3><CENTER>$cls->{'Name'}</H3>
<H3>Assignments</H3>
FORM
    ASSIGNMENT::print_listbox($cls,'published');
    print <<"FORM";
<BR>
<H4>
<INPUT TYPE=submit  NAME=cn_option VALUE=Complete>
<INPUT TYPE=submit  NAME=cn_option VALUE=Answers>
<INPUT TYPE=submit  NAME=cn_option VALUE=Scores>
FORM
    if (-e "$cls->{'Root Dir'}/scores.gif") {
        print "<INPUT TYPE=submit  NAME=cn_option VALUE=Histogram>"
    }
    print <<"FORM";
<INPUT TYPE=submit  NAME=cn_option VALUE="Personal Data">
<P><B>Communication</B><BR>
<INPUT TYPE=submit  NAME=cn_option VALUE=Email>
<INPUT TYPE=submit  NAME=cn_option VALUE=Discuss>
<INPUT TYPE=submit  NAME=cn_option VALUE=Chat>
<P>
<INPUT TYPE=submit  NAME=back VALUE="Logout">
</H4>
</CENTER>
$msg
FORM
    CN_UTILS::print_cn_footer("student_menu.html");
}

1;
