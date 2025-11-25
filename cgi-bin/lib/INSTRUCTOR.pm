package INSTRUCTOR;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader, MEMBER);
#@ISA = qw( MEMBER );

#########################################
=head1 INSTRUCTOR

Parent: MEMBER

=head1 Methods:

=cut
#########################################

#use SelfLoader;
require MEMBER;

#########################################
=head2 new($query, $cls, $uname)

=over 4

=item Description

Create a new instructor object (type of class member)

=item Params
$query: CGI parsed form object. This object may be null
if $uname is present

$cls: Course object

$uname: Unmodified username. Overridden by $query->{'Username'} if $query
is defined.

=item Returns
INSTRUCTOR Object

=back

=cut

sub new {
   my($class, $query, $cls, $uname) = @_;
   my $self = MEMBER->new($query, $cls, $uname);
   $self->{'Member Type'} = 'instructor';
   bless $self;
}

# Prevent AutoLoader from looking for DESTROY.al
sub DESTROY { }

__END__
#__DATA__

#########################################
=head2 add($cls, $priv)

=over 4

=item Description
Add an instructor to a course with certain privileges

=item Params
$cls: Course object representing course to which the teacher
is to be added.

$priv: Instructor privilege string separated by commas

=back

=cut

sub add {

   my($self, $cls, $priv) = @_;

   # Username must be unique
   $mem_type = $cls->mem_exists($self->{'Disk Username'});
   if ($mem_type) {
     &ERROR::user_error($ERROR::MEMBEREX,$self->{'Username'});
   }

   chdir("$self->{'Root Dir'}/admin/members/instructors");
   open(INST_FILE, ">$self->{'Disk Username'}") or 
     &ERROR::system_error("INSTRUCTOR","add","Open",self->{'Disk Username'});
   print INST_FILE "Password=$self->{'Password'}\n";
   print INST_FILE "Email Address=$self->{'Email Address'}\n";
   print INST_FILE "Priv=$priv\n";
   close(INST_FILE) or
     &ERROR::system_error("INSTRUCTOR","add","Close",self->{'Disk Username'}); 
   chmod(0600, $self->{'Disk Username'});
   $cls->add_to_mem_list('instructor',$self->{'Username'});

}

#########################################
=head2 exists()

=over 4

=item Description
Does this instructor already exist?  

=item Returns
BOOLEAN

=back

=cut

sub exists {

   my $self = shift;
   my $fname = "$self->{'Root Dir'}/admin/members/instructors/" . $self->{'Username'};
   (-e $fname);

}

#########################################
=head2 enroll_req_members($query, $cls)

=over 4

=item Description
Enroll those student requesting enrollment and
delete the rest.

=item Params
$query: CGI parsed form object

$cls: Class object to enroll students in

=back

=cut

sub enroll_req_members {
   my ($self, $query, $cls) = @_;
   my ($mem, $num_deletes, $num_adds, @add_list);

   # Set up the directories
   my $stud_dir_root = $self->{'Root Dir'} . "/admin/members/students";
   my $req_dir_root = $self->{'Root Dir'} . "/admin/members/requests";

   # Loop through the list of additions and enroll those students
   # The student usernames are already escaped
   my @enroll_list = $query->param();
   my $txt = "";
   $num_adds = 0; $num_dels = 0;
   foreach $mem (@enroll_list) {
       if ($mem =~ /^STU_/) {
           my $op = $query->param($mem);
           $mem = substr($mem,4);
           my $disk_uname = CGI::unescape($mem);
           $disk_uname = CN_UTILS::get_disk_name($disk_uname);
           if ($op eq 'app') {
               my $req_file = "$req_dir_root/$disk_uname";
               my $stud_file = "$stud_dir_root/$disk_uname";
               if (!(-e $stud_file) and (-e $req_file)) {
       	           rename ($req_file, $stud_file);
       	           $cls->create_stud_dirs($disk_uname);
       	           push (@add_list, $mem);
                   push (@del_list, $disk_uname);
                   $num_adds++;
       	           $txt .= "Username $mem was added.\n";
                   my %info = $cls->get_mem_info($mem);
                   CN_UTILS::mail($info{'Email Address'},"Username $mem approved",
                       "Username '$mem' is ready for use in ClassNet class $cls->{'Name'}.");
               }
               elsif (-e $stud_file) {
       	           $txt .= "Username $mem is already enrolled.\n";
               }
               else {
       	           $txt .= "Username $mem is not on the request list.\n";
               }
            } elsif ($op eq "rej") {
                push(@del_list,$disk_uname);
                $num_dels++;
            }
        }
    }

   $cls->add_to_mem_list('student', @add_list);
    # Remove the rejected requests
   chdir($req_dir_root);
   unlink @del_list;
   $txt .= "\nStudents added: $num_adds\nRequests rejected: $num_dels\n";
   CN_UTILS::mail($self->{'Email Address'},"Enrollment Update for $cls->{'Name'}",$txt);
    $cls->member_menu($self);
    exit(0);
}

#########################################
=head2 delete_member($cls, $mem_name)

=over 4

=item Description
Delete class member from a class

=item Params
$cls: Course Object

$mem_name: name of member to delete

=item Returns
Boolean ("" or $mem_name)

=back

=cut

sub delete_member {
   my ($self, $cls, $mem_name) = @_;

   #Cannot delete owner
   my $member = $cls->get_member(0,$mem_name);

   return "" if $member->{'Priv'} eq 'owner';

   if ($member->{'Member Type'} =~ m/student/) {
       unlink "$cls->{'Root Dir'}/admin/members/students/$member->{'Disk Username'}";
       my $assign_dir = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}";
       system("rm -f -r $assign_dir");
   }
   else { 
       unlink "$cls->{'Root Dir'}/admin/members/instructors/$member->{'Disk Username'}";
   } 

   $cls->remove_from_mem_list($member->{'Member Type'}, $mem_name);
   return $mem_name;
      
}

#########################################
=head2 print_menu($cls)

=over 4

=item Description
Print Instructor Menu

=item Params
$cls: Class Object


=item Returns
none

=back

=cut

sub print_menu {
    my ($self,$cls) = @_;
    my @req_list = $cls->get_mem_names('requests');
    my $req_len = @req_list;
    my $msg = '';
    if ($req_len > 0) {
       	$msg .= "<font color=#a40000>Enrollment approval required (see Members)</font><BR>";
    }
    $msg .= $cls->last_access();
    CN_UTILS::print_cn_header("Instructor Menu");
    print <<"FORM";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/instructor>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<H3><CENTER>$cls->{'Name'}</H3>
<H4>
<INPUT TYPE=submit  NAME=cn_option VALUE=Members>
<INPUT TYPE=submit  NAME=cn_option VALUE=Assignments>
<INPUT TYPE=submit  NAME=cn_option VALUE=Gradebook>
<BR>
<INPUT TYPE=submit  NAME=cn_option VALUE="Class Options">
<INPUT TYPE=submit  NAME=cn_option VALUE="Personal Data">
<P><B>Communication</B><BR>
<INPUT TYPE=submit  NAME=cn_option VALUE=Email>
<INPUT TYPE=submit  NAME=cn_option VALUE=Discuss>
<INPUT TYPE=submit  NAME=cn_option VALUE="Edit Discussion">
<INPUT TYPE=submit  NAME=cn_option VALUE=Chat>
<P>
<INPUT TYPE=submit  NAME=cn_option VALUE="Logout">
</H4>
</FORM>
</CENTER>
$msg
FORM
    CN_UTILS::print_cn_footer("instructor_menu.html");
}

1;







