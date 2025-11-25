package CLASS;
use Exporter;
@ISA = (Exporter);

#########################################
=head1 CLASS

=head1 Methods:

=cut
#########################################

require INSTRUCTOR;
require STUDENT;
require ASSIGNMENT;
require TEST;
require FORECAST;
require INCLASS;
require JAVA;
require EVAL;
require DIALOG;

#########################################
=head2 new($cls_name)

=over 4

=item Description
Create a new CLASS object 

=item Params
$cls_name: Unmodified class name 

=item Instance Variables

$self->{'Name'}: Unmodified class name. It is not escaped,
not converted to upper case, and does not have leading or 
trailing blanks removed.

$self->{'Disk Name'}: Modified class name

$self->{'Root Dir'}: Class root directory
(e.g. /local/classnet/data/class_name).

$self->{'Enroll Opt'}: Set to 'auto' for automatic 
enrollment or to 'controlled' for controlled enrollment

$self->{'Expiration Month'}: Month Year

=item Returns
CLASS object 

=back

=cut

sub new {
   my($class, $cls_name) = @_;
   my $self = {};
   bless $self, $class;

   # Save user entered class name
   $self->{'Name'} = $cls_name;
   # Get disk version of class name
   $self->{'Disk Name'} = CN_UTILS::get_disk_name($cls_name);

   $self->{'Root Dir'} = "$GLOBALS::CLASSNET_ROOT_DIR/$self->{'Disk Name'}";
   if ($self->exists()) {
       chdir($self->{'Root Dir'});
       $self->get_reg_options();
   }
   return $self;
}

#########################################
=head2 exists()

=over 4

=item Description
Does this class already exists in the database? 

=item Returns
BOOLEAN

=back

=cut

sub exists {
   my $self = shift;
   (-e $self->{'Root Dir'});
}

#########################################
=head2 get_reg_options()

=over 4

=item Description
Get class registration options in the receiver object: 
'Verify Enrollment' = 0(open),1(approval),2(closed)
'Expiration Month' = Mon Year
'ShowComm' = yes,no
=back

=cut

sub get_reg_options {
   my $self = shift;

   # Read options from reg_options file if it exists
   my $reg_opt_file = "$self->{'Root Dir'}/admin/reg_options";
   if (-e $reg_opt_file) {
       open(REG_OPT, "<$reg_opt_file") or 
       	   ERROR::system_error("CLASS","get_reg_options","Open",$reg_opt_file);
       flock(REG_OPT, $LOCK_EX);
       while (<REG_OPT>) {
       	   chop;
       	   my ($option, $value) = split(/=/);
       	   $self->{$option} = $value;
       }
       flock(REG_OPT, $LOCK_UN);
       close(REG_OPT);
   }
}

#########################################
=head2 set_reg_options($enroll,$month,$showcomm)

=over 4

=item Description
Set class registration options in admin/options file: 
$enroll = 'Verify Enrollment' = 0(open),1(approval),2(closed)
$month  = 'Expiration Month' = Mon Year
$showcomm = 'ShowComm' = yes,no
=back

=cut

sub set_reg_options {
   my ($self, $enroll,$month,$showcomm) = @_;
   # Set options in admin/reg_options;
   my $fname = "$self->{'Root Dir'}/admin/reg_options";
   open(REG_OPT, ">$fname") or 
       ERROR::system_error("INSTRUCTOR","set_reg_options","Open",$fname);
   flock(REG_OPT, $LOCK_EX);
   print REG_OPT "Verify Enrollment=$enroll\n";
   print REG_OPT "Expiration Month=$month\n";
   print REG_OPT "ShowComm=$showcomm\n";
   flock(REG_OPT, $LOCK_EX);
   close(REG_OPT) or
       ERROR::system_error("CLASS","set_reg_options","Close",$fname);
   chmod(0600, $fname);
}

#########################################
=head2 create_dir_structure()

=over 4

=item Description
Creates the class directory structure 

=back

=cut

sub create_dir_structure {
   my $self = shift;

   # Create the directories
   mkdir($self->{'Root Dir'},0700) or
       &ERROR::system_error("CLASS","create_dir_structure","mkdir1",$self->{'Root Dir'});
   chdir($self->{'Root Dir'});
   (mkdir('admin',0700) and mkdir('admin/members',0700) and mkdir('admin/member_lists',0700) and
    mkdir('admin/members/requests',0700) and mkdir('admin/members/instructors',0700) and
    mkdir('admin/members/students',0700) and mkdir('assignments',0700) and mkdir('students',0700)) 
       or
   &ERROR::system_error("CLASS","create_dir_structure","mkdir2",$self->{'Name'});
}

#########################################
=head2 create_stud_dirs($disk_uname)

=over 4

=item Description
Create the student assignment directories

=item Params
$disk_uname: Disk username of the student.

=back

=cut

sub create_stud_dirs {

   my ($self, $disk_uname) = @_;

   my $stud_root_dir = "$self->{'Root Dir'}/students/$disk_uname";
   my $uname = CGI::unescape($disk_uname);
   mkdir($stud_root_dir,0700) or
      ERROR::system_error("CLASS","create_stud_dirs","mkdir root",$stud_root_dir);
   chdir($stud_root_dir);
   (mkdir('graded',0700) and 
    mkdir('ungraded',0700) and
    mkdir('dialog',0700) and
    mkdir('java',0700)) or
      ERROR::system_error(CLASS,"create_stud_dirs","mkdir graded",$stud_root_dir);
}

#########################################
=head2 add_to_classlist()

=over 4

=item Description
Adds the class name to the class list file

=item Params
none

=back

=cut

sub add_to_classlist {

   my ($name) = @_;
   my @class_names = list();
   push (@class_names, $name);
   open(CLASS_LIST, ">$GLOBALS::CLASSNET_ROOT_DIR/class_list") or 
       &ERROR::system_error("CLASS","create","open","class list");
   $, = "\n";
   print CLASS_LIST sort { uc($a) cmp uc($b)} @class_names;
   print CLASS_LIST "\n";
   close(CLASS_LIST);
   chmod 0700, "$GLOBALS::CLASSNET_ROOT_DIR/class_list";
}

#########################################
=head2 remove_from_classlist()

=over 4

=item Description
Removes the class name from the class list file

=item Params
none

=back

=cut

sub remove_from_classlist {
   my ($name) = @_;
   my @class_list = list();

   for ($i = 0; ( ($i < @class_list) and ($name ne $class_list[$i]) ); $i++) {}
   if ($i < @class_list) {
       splice(@class_list,$i,1);   
       open(CLASS_LIST, ">$GLOBALS::CLASSNET_ROOT_DIR/class_list") or 
       	   &ERROR::system_error("CLASS","remove_from_class_list","Open",$mem_type);
       $, = "\n";
       print CLASS_LIST @class_list;
       print CLASS_LIST "\n";
       close(CLASS_LIST);
       chmod 0700, "$GLOBALS::CLASSNET_ROOT_DIR/class_list";
   }
}

#########################################
=head2 check_limit()

=over 4

=item Description
Checks to see if the limit on the number of classes has been reached

=item Params
$query: CGI parsed form object 

=back

=cut

sub check_limit {
   # Has the maximum number of classes been reached? 
   opendir(CLASS_DIR,$GLOBALS::CLASSNET_ROOT_DIR);  
   # Don't include . or .. directories
   my $num_classes = grep(!/^\.\.?$/, readdir(CLASS_DIR));
   closedir(CLASS_DIR);
   if ($num_classes >= $GLOBALS::MAX_CLASS) {
      ERROR::user_error($ERROR::CLASSLIMIT,$GLOBALS::MAX_CLASS);
   }
}

#########################################
=head2 create()

=over 4

=item Description
Create a new class in the database. Class
information is taked from the HTML form through
the $query object.

=item Params
none

=back

=cut

sub create {
   my ($self) = @_;

   # Does this class already exist?
   if ($self->exists()) {
       ERROR::user_error($ERROR::CLASSEX,$self->{'Name'});
   }

   # Create the directories
   $self->create_dir_structure();

}

#########################################
=head2 get_member($query, $uname)

=over 4

=item Description
Get a member (instructor or student) of a class. If the 
user designated by $uname is requesting enrollment or 
does not exist in the class, the script dies with an
HTML error message returned. if $uname is not defined,
then the Username is taken from $query.

=item Params
$query: CGI parsed form object

$uname: Unmodified username

=item Returns
MEMBER object (INSTRUCTOR or STUDENT)

=back

=cut

sub get_member {
   my ($self, $query, $uname) = @_;
   my $mem,$tkt;

   # Change Username to disk representation;

   if (!(defined $uname)) {
       # get the ticket filename from the query
       $tkt = $query->param('Ticket');
       my $ticketfile = "$GLOBALS::TICKET_DIR/$tkt";
       if (-e $ticketfile) {
           (open(TICKET_FILE, "<$ticketfile")) or
         	   &ERROR::system_error("CLASS","get_member","Open",$ticketfile);
           @line = <TICKET_FILE>;
           close(TICKET_FILE);
           chomp(@line);
           $uname = $line[0];
       } else {
       	   ERROR::user_error($ERROR::NOTICKET);
       }
   }
   $query->{'Username'}->[0] = $uname;
   my $disk_uname = CN_UTILS::get_disk_name($uname);
   my $mem_type = $self->mem_exists($disk_uname);

   if ($mem_type eq 'instructor') {
       $mem = INSTRUCTOR->new($query, $self, $uname); 
   }
   elsif ($mem_type eq 'student') {
       $mem = STUDENT->new($query, $self, $uname);
       # Is a student attempting an instructor option?
       if ( (defined $query->{'cn_option'}->[0]) and 
		(index("inst",$query->{'cn_option'}->[0]) == 0)) {
       	       ERROR::user_error($ERROR::NOPERM);
       }
   }
   elsif ($mem_type eq 'requests') {
       ERROR::user_error($ERROR::ENROLL);
   }
   else {
       ERROR::user_error($ERROR::MEMBERNF,$uname);
   }

   $mem->{'Member Type'} = $mem_type;
   $mem->{'Ticket'} = $tkt;
   return $mem;  

}

#########################################
=head2 mem_exists($disk_uname)

=over 4
=item Description
This method determines if the user identified by $disk_uname
or exists anywhere in the course.

=item Params
$disk_uname: Disk username of member you are
searching for.

=item Returns
If the member does not exist, then return "";
else return  the member type: 'student',
'instructor', or 'requests'. The reason for
plural is it contains the member type and
the exact directory name

=back

=cut

sub mem_exists {

   my ($self, $disk_uname) = @_;

   # Enrolled student?
   my $fname = "$self->{'Root Dir'}/admin/members/students/$disk_uname";
   if (-e $fname) {
       return 'student';
   }

   # Requesting student?
   $fname = "$self->{'Root Dir'}/admin/members/requests/$disk_uname";
   return 'requests' if (-e $fname);

   # Instructor?
   $fname = "$self->{'Root Dir'}/admin/members/instructors/$disk_uname";
   (-e $fname) ? 'instructor' : "";
}

sub get_uname {
   my ($self, $email) = @_;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   if (!(-e $fname)) {
       open(EFILE,">$fname") or
           &ERROR::system_error("CLASS","get_uname","create $fname",$email);
       flock(EFILE, LOCK_EX);
       my @members = $self->get_mem_names('instructor');
       push(@members,$self->get_mem_names('student'));
       foreach $member (@members) {
           my $val = $self->get_email_addr($member); 
           print EFILE "$val=$member\n";
       }
       flock(EFILE,UNLOCK);
       close(EFILE);
   }
   open(ELIST,"<$fname") or
       &ERROR::system_error("CLASS","get_uname","open $fname",$email);
   my @list = <ELIST>;
   close ELIST;
   chomp(@list);
   foreach $line (@list) {
       my ($key,$uname)=split(/=/,$line);
       if ($key eq $email) {
           return $uname;
       }
   }
   return '';
}

sub get_email_addr {
   my ($self,$uname) = @_;

   my $disk_uname = CN_UTILS::get_disk_name($uname);
   my $mem_type = $self->mem_exists($disk_uname);
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$disk_uname";
   open(MEM_FILE, "<$fname") or
       ERROR::user_error($ERROR::MEMBERNF,$uname);
   while (<MEM_FILE>) {
       chop;
       my ($name,$value) = split(/=/);
       if ($name eq 'Email Address') {
           return $value;
       }
   }
   return '';
}

#########################################
=head2 get_mem_info($disk_uname)

=over 4

=item Description
Get information about a given member.
The member is searched for in the student
directory first, followed by the instructor directory
and finally the requests directory.

=item Params
$disk_uname: Disk username

=item Returns
An associative array of name/value information: $pair{'name'} = 'value'

=back

=cut

sub get_mem_info {
   my ($self,$uname) = @_;
   my %pairs;

   my $disk_uname = CN_UTILS::get_disk_name($uname);
   my $mem_type = $self->mem_exists($disk_uname);
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$disk_uname";
   open(MEM_FILE, "<$fname") or
       ERROR::user_error($ERROR::MEMBERNF,$uname);

#   flock($fname, LOCK_EX);
   chop($pair{'Member Type'} = $mem_type);
   while (<MEM_FILE>) {
       chop;
       my ($name,$value) = split(/=/);
       $pairs{$name} = $value;
   }
   ($pairs{'Last Name'}, $pairs{'First Name'}) = split(/, /,$uname);
   return %pairs;
}

#########################################
=head2 get_cls_mem_info($mem_type)

=over 4

=item Description
Get information about all members of a certain type
in a given course

=item Params
$mem_type: 'instructor', 'student', or 'requests'

=item Returns
An associative array with key = "Last_Name, First_Name::disk_uname"
and with each element = email address. The key is guaranteed to
be unique.

=back

=cut

sub get_cls_mem_info {
   my ($self, $mem_type) = @_;
   my (@members, %mem_info_list);

   @members = $self->get_mem_names($mem_type);

   return "" unless @members;

   # Create a hash of lists
   #  $mem_info_list{last_name, first_name} => [email address, password]
   foreach $member (@members) {
       my %pair = $self->get_mem_info($member);
       $mem_info_list{$member} = [$pair{'Email Address'}, $pair{'Password'}, $pair{'Priv'}];
   }
   return %mem_info_list;
}

#########################################
=head2 add_to_mem_list($mem_type, @name_list)

=over 4

=item Description
Adds instructor/student names to a class list of instructors/students

=item Params
$mem_type: 'instructor', 'student'

@name_list: list of names (Last Name, First Name)

=back

=cut

sub add_to_mem_list {
   my ($self, $mem_type, @name_list) = @_;

   my $fname = "$self->{'Root Dir'}/admin/member_lists/${mem_type}s";
   # Add class to classlist file
   open(MEM_LIST, "<$fname");
   my @mem_names = <MEM_LIST>;
   push (@mem_names, @name_list);
   open(MEM_LIST, ">$fname") or 
       	   &ERROR::system_error("CLASS","add_to_mem_list","Open list",$mem_type);
   flock(MEM_LIST,$LOCK_EX);
   chomp (@mem_names = sort @mem_names);
   $, = "\n";
   print MEM_LIST @mem_names;
   flock(MEM_LIST,$LOCK_UN);
   close(MEM_LIST);
   chmod 0700, $fname;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   unlink $fname;
}
#########################################
=head2 remove_from_mem_list($mem_type, $mem_name)

=over 4

=item Description
Deletes instructor/student from class list

=item Params
$mem_type: 'instructor', 'student'

$mem_name: Member name to be deleted

=back

=cut

sub remove_from_mem_list {
   my ($self, $mem_type, $mem_name) = @_;
   my $i;

   my $fname = "$self->{'Root Dir'}/admin/member_lists/${mem_type}s";
   # Get list of members
   open(MEM_LIST, "<$fname");
   my @mem_list = <MEM_LIST>;
   chomp @mem_list;

   for ($i = 0; ( ($i < @mem_list) and ($mem_name ne $mem_list[$i]) ); $i++) {}
   splice(@mem_list,$i,1);   
       	   
   open(MEM_LIST, ">$fname") or 
       	   &ERROR::system_error("CLASS","remove_from_mem_list","Open",$mem_type);
   $, = "\n";
   flock(MEM_LIST,$LOCK_EX);
   print MEM_LIST @mem_list;
   flock(MEM_LIST,$LOCK_UN);
   close(MEM_LIST);
   chmod 0700, $fname;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   unlink $fname;
}

#########################################
=head2 get_mem_names($mem_type)

=over 4

=item Description
Gets instructor or student names

=item Params
$mem_type: 'instructor', 'student', 'requests'

=item Returns
@name_list: list of names (Last Name, First Name)

=back

=cut

sub get_mem_names {
   my ($self, $mem_type) = @_;
   my @mem_names;

   if ($mem_type eq 'requests') {
       opendir(MEM_LIST,"$self->{'Root Dir'}/admin/members/requests") or
       	   ERROR::system_error("CLASS", "get_cls_mem_info",
                               "opendir $mem_type",$self->{'Root Dir'});
       @mem_names = grep (!/^\./,readdir(MEM_LIST));
       closedir(MEM_LIST);
       foreach $member (@mem_names) {
       	   $member = CGI::unescape($member);
       }
   } else {
       $/ = "\n";
       open(MEM_LIST, "<$self->{'Root Dir'}/admin/member_lists/${mem_type}s");
       chomp (@mem_names = <MEM_LIST>);
       close(MEM_LIST);
   }
   return @mem_names;
}

#########################################
=head2 owner()

=over 4

=item Description
Returns the owner of the class

=item Params
none

=item Returns
%inst: owner record

=back

=cut

sub owner {
    my ($self) = @_;
    %inst_info = $self->get_cls_mem_info('instructor');
    foreach $name (keys %inst_info) {
        $priv = $inst_info{$name}[2];
        if ($priv =~ /owner/) {
            return INSTRUCTOR->new(NIL,$self,$name);
        }
    }

}

#########################################
=head2 archive()

=over 4

=item Description
Archive the class directory to the archival directory and remove name
from class_list

=item Params
None

=item Returns
none

=back

=cut

sub archive {
  my ($name) = @_;
  my $self = CLASS->new($name);
  my $dname = "$GLOBALS::ARCHIVE_ROOT_DIR/classes";
  system("cp -r $self->{'Root Dir'} $dname") and
    ERROR::system_error("CLASS","archive","copy","$name:$!");
  system("rm -r $self->{'Root Dir'}") and
    ERROR::system_error("CLASS","archive","rm -r","$name:$!");
  remove_from_classlist($name);
}

#########################################
=head2 expired()

=over 4

=item Description
Returns true if Class expiration date has passed

=item Params
None

=item Returns
none

=back

=cut

sub expired {
    my ($self) = @_;
    ($mon,$year) = split(/ /,$self->{'Expiration Month'});
    @monname = ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');
    for ($i=0; $i < 12 && $monname[$i] ne $mon; $i++){};
    $cls_tot = $i + 12 * $year;
    $year = (localtime)[5] + 1900;
    $cur_tot = (localtime)[4] + 12 * $year;
    return $cur_tot >= $cls_tot;  
}

#########################################
=head2 list()

=over 4

=item Description
Returns a list of classes

=item Params
None

=item Returns
none

=back

=cut

sub list {
    my $class = shift; # Handle method call - ignore class arg
          
open(CLASS_LIST, "<$GLOBALS::CLASSNET_ROOT_DIR/class_list") or
    &ERROR::system_error("CLASS","list","open",
                         "$GLOBALS::CLASSNET_ROOT_DIR/class_list");
    my @list = <CLASS_LIST>;
    chop @list;
    close CLASS_LIST;
    return @list;
}

#########################################
=head2 member_menu()

=over 4

=item Description
Generate a member menu

=item Params
None

=item Returns
none

=back

=cut

sub member_menu {
    my ($self,$inst) = @_;
    # Get list of students (Student list may not actually exist)
    if (open(STUDENTS,"<$GLOBALS::CLASSNET_ROOT_DIR/$self->{'Disk Name'}/admin/member_lists/students")) {
        @members = <STUDENTS>;
       	close(STUDENTS);
    }

    # Get list of instructors
    $inst_fname = "$GLOBALS::CLASSNET_ROOT_DIR/$self->{'Disk Name'}/admin/member_lists/instructors";
    open(INSTRUCTORS,"<$inst_fname") or
       	&ERROR::system_error("Instructor","membership","open",$inst_fname);
    @instructors = <INSTRUCTORS>;
    close(INSTRUCTORS);
    push(@members,@instructors);

    CN_UTILS::print_cn_header("Members");

    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER><H3>$self->{'Name'}</H3>
<SELECT NAME="Members" SIZE=10>
FORM
    foreach $member (sort @members) {
        print qq|<OPTION> $member\n|;
    }
       	       
    print <<"FORM";
</SELECT>
<P>
<H4>
<INPUT TYPE=submit NAME=cn_option VALUE=Edit>
 <INPUT TYPE=submit NAME=cn_option VALUE=Delete>
 <INPUT TYPE=submit NAME=cn_option VALUE=Add>
 <INPUT TYPE=submit NAME=cn_option VALUE=Upload>
<BR>
 <INPUT TYPE=submit NAME=cn_option VALUE=List>
 <INPUT TYPE=submit NAME=cn_option VALUE=Renew>
FORM
    my @req_list = $self->get_mem_names('requests');
    my $req_len = @req_list;
    if ($req_len > 0) {
       	print "<BR><INPUT TYPE=submit NAME=cn_option VALUE=Approve>";
    }
    print <<"FORM";
<BR>
<INPUT TYPE=submit NAME=cn_option VALUE="Instructor Menu">
</CENTER>
FORM
    CN_UTILS::print_cn_footer("membership.html");
}

#########################################
=head2 print_member_list()

=over 4

=item Description
Print list of members

=item Params
None

=item Returns
none

=back

=cut

sub print_member_list {
    my ($self) = @_;

    %inst_info_list = $self->get_cls_mem_info('instructor');
    %stud_info_list = $self->get_cls_mem_info('student');

    # Send the list
    CN_UTILS::print_cn_header("Membership List");
    print qq|<CENTER><H3>$self->{'Name'}</H3></CENTER>|;
    print qq|<CENTER><H2>Instructors</H2></CENTER><DL>|;
    foreach $key (sort (keys %inst_info_list)) {
       	# Change to verbose format
       	$privs = $inst_info_list{$key}[2];
       	$privs =~ s/assignments/Manage assignments/;
       	$privs =~ s/students/Manage students/;
       	print qq|<DT><b>$key</b>\n|;
       	print qq|<DD>$inst_info_list{$key}[0]<DD>$privs\n|;
    }

    print qq|</DL><CENTER><H2>$GLOBALS::HR<BR>Students</H2></CENTER><DL>|;
    foreach $key (sort (keys %stud_info_list)) {
       	print qq|<DT><b>$key</b>\n|;
       	print qq|<DD>$stud_info_list{$key}[0]\n|;
    }
    print qq|</DL><CENTER>$GLOBALS::HR</CENTER><br>|;
}

#########################################
=head2 print_approval_list()

=over 4

=item Description
Print list of members which need to be approved

=item Params
$inst: Instructor Object

=item Returns
none

=back

=cut

sub print_approval_list {
    my ($self,$inst) = @_;

    my @mem_list = $self->get_mem_names('requests');
    my $req_dir_root = $self->{'Root Dir'} . "/admin/members/requests";

    # Send the list
    CN_UTILS::print_cn_header("Approve Students");
    print qq|<CENTER><H3>$self->{'Name'}</H3></CENTER>\n|;
    print <<"START";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Enroll Request Members">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER>
<TABLE WIDTH="50%" BORDER>
<TR><TH>Name<TH>Email<TH>A Addresspprove<TH>Reject<TH>Retain</TR>
START
    foreach $name (sort @mem_list) {
        my $disk_uname = CGI::unescape($name);
        $disk_uname = CN_UTILS::get_disk_name($disk_uname);
        my $email = "";
        open(REQ_FILE, "<$disk_uname") or 
            &ERROR::system_error("INSTRUCTOR","approval","Open",$disk_uname);
        while (<REW_FILE>) {
           chop;
       	   my ($option, $value) = split(/=/);
       	   if ($option eq 'Email Address') {
              $email = $value;
           }
        }
        close(REQ_FILE);
       	print qq|<TR ALIGN=CENTER><TD>$name|;
       	print qq|<TD><a href="email:$email|">$email</a>;
	print qq|<TD><INPUT TYPE=radio NAME="STU_$name" VALUE="app" CHECKED>|;
       	print qq|<TD><INPUT TYPE=radio NAME="STU_$name" VALUE="rej">|;
       	print qq|<TD><INPUT TYPE=radio NAME="STU_$name" VALUE="ret">|;
        print qq|</TR>|;
    }
    print <<"END";
</TABLE>
</CENTER>
<P>
Approve will add the student to the class.<BR>
Reject will delete the request and not add the student.<BR>
Retain will keep the request for future consideration.
<H4><CENTER><INPUT TYPE=submit Value=Submit></CENTER></H4><p>
</FORM>
END
    CN_UTILS::print_cn_footer("approve_students.html");
}

#########################################
=head2 print_gradebook()

=over 4

=item Description
Print gradebook menu

=item Params
none

=item Returns
none

=back

=cut

sub print_gradebook {
    my ($self,$inst) = @_;
    
    my @students = $self->get_mem_names('student');
    my $hasTable = CN_UTILS::hasTables();
    CN_UTILS::print_cn_header("Gradebook");
    print <<"GRADEBOOK";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/gradebook>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER>
<H3>$self->{'Name'}</H3>
GRADEBOOK
    if ($hasTable) {
        print "<TABLE border=0 width=50%>";
        print "<TH ALIGN=CENTER><B>Assignments</B>\n";
        print "<TH ALIGN=CENTER><B>Students</B>\n";
        print "<TR><TD ALIGN=CENTER>\n";
        ASSIGNMENT->print_listbox($self,'published','MULTIPLE');
        print "<TD ALIGN=CENTER>\n";
        print "<SELECT MULTIPLE SIZE=5 NAME=student>\n";
        foreach $mem_name (sort @students) {
            print "<OPTION> $mem_name\n";
        }
        print "</SELECT>\n<TR>";
        print "<TD ALIGN=CENTER><INPUT TYPE=checkbox NAME=\"All Assignments\"> All\n";
        print "<TD ALIGN=CENTER><INPUT TYPE=checkbox NAME=\"All Students\"> All\n";
        print "</TABLE>\n";
    } else {
        print "<B> Assignments </B><BR>";
        ASSIGNMENT->print_listbox($self,'published','MULTIPLE');
        print "<BR><INPUT TYPE=checkbox NAME=\"All Assignments\"> All\n";
        print "<P><B> Students </B><BR><SELECT MULTIPLE SIZE=5 NAME=student>\n";
        foreach $mem_name (sort @students) {
            print "<OPTION> $mem_name\n";
        }
        print "</SELECT><BR>\n";
        print "<INPUT TYPE=checkbox NAME=\"All Students\"> All\n";
    }
    print <<"GRADEBOOK";
<P>
<H4>
<INPUT TYPE=submit NAME=cn_option VALUE=Scores> 
<INPUT TYPE=submit NAME=cn_option VALUE=Statistics> 
<INPUT TYPE=submit NAME=cn_option VALUE=Grade>
<INPUT TYPE=submit NAME=cn_option VALUE=Ungrade>
<INPUT TYPE=submit NAME=cn_option VALUE=Histogram>
<INPUT TYPE=submit NAME=cn_option VALUE=Data>
<BR> 
<INPUT TYPE=submit NAME=cn_option VALUE=Edit> 
<INPUT TYPE=submit NAME=cn_option VALUE=Delete> 
<INPUT TYPE=submit NAME=cn_option VALUE=Add> 
<BR>
<INPUT TYPE=submit NAME=back VALUE="Instructor Menu">
</CENTER>
GRADEBOOK
    CN_UTILS::print_cn_footer("gradebook.html");
}

#########################################
=head2 print_login()

=over 4

=item Description
Print login page for this class

=item Params
none

=item Returns
none

=back

=cut

sub print_login {
    my ($self) = @_;
    CN_UTILS::print_cn_header("Identification");
    print <<"END_FORM";
<FORM METHOD="POST" ACTION="$GLOBALS::SECURE_SCRIPT_ROOT/get_login">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="cn_option" VALUE="Get Menu">
<CENTER><B>$self->{'Name'}</B></CENTER><BR>
<table align="center">
<tr>
<td>
<pre>
<B>Email:    </B><INPUT NAME=Email><BR>
<B>Password: </B><INPUT TYPE=Password NAME=Password>
</pre>
</td>
</tr>
</table>
<CENTER><B><INPUT TYPE=submit Value=Login> <INPUT TYPE=reset></B>
<P><a 
href="$GLOBALS::SERVER_ROOT/help/get_login.html#password">Forget 
your Password?</a>
</CENTER>
</FORM>
$GLOBALS::HR
<CENTER><img SRC="$GLOBALS::SERVER_IMAGES/warning.gif" ALT="Warning">
</CENTER>   
<BLOCKQUOTE>
To protect your personal information you should
<B>Exit your Browser completely</B> when finished. See help for details.<BR>
<b>All information viewed while using a ClassNet class is for class use and 
may not be shared with individuals not enrolled in the class.<b>
<BR>If your  name is not on the list, you need to 
<a href="$GLOBALS::SECURE_SERVER_ROOT/cgi-bin/get_stud_reg_form">Join the 
ClassNet class</a> before you can enter it.
</BLOCKQUOTE>
END_FORM
   CN_UTILS::print_cn_footer("get_login.html");
}

#########################################
=head2 print_main_menu()

=over 4

=item Description
Print main menu of ClassNet

=item Params
none

=item Returns
none

=back

=cut

sub print_main_menu {
    @cls_files = CLASS->list();

    CN_UTILS::print_cn_header("Main Menu");

    print <<"START_FORM";
<FORM METHOD="POST" ACTION="$GLOBALS::SECURE_SCRIPT_ROOT/get_login">
<INPUT TYPE=hidden NAME="cn_option" VALUE="Get Login">
<TABLE WIDTH=60%>
<TR ALIGN="CENTER">
<TD ALIGN="LEFT"><CENTER><B>Login Directions</B></CENTER>
Step 1. Click on a class name<BR>
Step 2. Click on Login<BR>
<P>
<B>First-time Options</B><BR>
<B>Students:</B> <A 
HREF="$GLOBALS::SECURE_SCRIPT_ROOT/get_stud_reg_form">Join a 
ClassNet class</A><BR>
<B>Instructors:</B> <A 
HREF="$GLOBALS::SECURE_SCRIPT_ROOT/get_class_reg_form">Create a 
ClassNet class</A>
</TD>
<TD>
<B>Classes</B><BR>
<SELECT SIZE=8  NAME="Class Name">
START_FORM
   
    foreach $cls_name (@cls_files) {
       print qq|<OPTION> $cls_name\n|;
    }

    print <<"END_FORM"
</SELECT>
<P>
<B><INPUT NAME="name" TYPE="submit" VALUE="Login"></B>
</TD>
</TR>
</TABLE>
<HR SIZE="4">
<CENTER>
$GLOBALS::RED_BALL<A HREF="$GLOBALS::SERVER_ROOT/help/index.html">Help</A> 
$GLOBALS::RED_BALL<A HREF="$GLOBALS::MAIL">Questions?</A>
$GLOBALS::RED_BALL<A HREF="$GLOBALS::SERVER_ROOT/credits.html">Credits</A>
</CENTER>
</FORM>
END_FORM
    
   CN_UTILS::print_cn_footer();
}

#########################################
=head2 submit_edit_changes($query)

=over 4

=item Description

=item Params

=item Returns


=back

=cut

sub submit_edit_changes {
   my ($self,$query) = @_;

   my $stud_name = $query->param('Student Username');
   my $asn_name = $query->param('Assignment Name');
   !($stud_name and $asn_name) and
       ERROR::system_error('CLASS','submit_edit_changes','',
       	   "Finding student ($stud_name) and asn name ($asn_name) in query");
   my $stud = $self->get_member("",$stud_name);
   my $asn = $self->get_assignment("",$stud,$asn_name);
   $asn->submit_edit_changes($query);
}

#########################################
=head2 get_assignment($query,$mem,$asn_name)

=over 4

=item Description
Retrieve an existing assignment

=item Params
$query: The CGI query object

$mem: the MEMBER object

$asn_name: ASSIGNMENT name (optional)

=item Returns
An assignment object

=back

=cut

sub get_assignment {
    my ($self,$query,$mem,$asn_name) = @_;
    $asn_name or $asn_name = $query->param('Assignment Name');
    if (defined $asn_name) {
        # find the assignment type
        my %asn_info = ASSIGNMENT->get_info($self,$asn_name);
        my $asn_type = $asn_info{'Assignment Type'};
        # Fallback for legacy FORECAST assignments without TYPE in options
        if (!$asn_type && $asn_name =~ /^forecast$/i) {
            $asn_type = 'FORECAST';
        }
        if ($asn_type) {
            return ($asn_type)->new($query,$self,$mem,$asn_name);
        } else {
            ERROR::user_error($ERROR::NOASNTYPE, $asn_name);
        }
    }
}


#########################################
=head2 send_edit_form($query,$asn_name,$stu)

=over 4

=item Description

=item Params
$query: form CGI query
$asn_name: name of assignment
$stu: list of students

=item Returns


=back

=cut

sub send_edit_form {
   my ($self,$query,$asn_name,$stu) = @_;
   my @snames = @{$stu};
   my $nstu = @snames;
   if ($nstu < 1) {
      ERROR::print_error_header('Edit?');
      print "Please select at least one student.";
      CN_UTILS::print_cn_footer();
      exit(0);
   }
   my $mem = $self->get_member('',$snames[0]);
   my $asn = $self->get_assignment('',$mem,$asn_name);
   $asn->send_edit_form($query,\@snames);
}

sub grade {
   my ($self,$stud_names,$asn_names) = @_;

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   # Get class names and set up dummy student object
   my @snames = @{$stud_names};
   my $stud_name = shift @snames;
   my $stud_obj = $self->get_member("",$stud_name);
   unshift(@snames,$stud_name);

   foreach $asn_name (@{$asn_names}) {
       my $asn = $self->get_assignment("",$stud_obj,$asn_name);
       foreach $stud_name (@snames) {
       	   my $stud_disk_name = CN_UTILS::get_disk_name($stud_name);
       	   !$asn and
       	       $asn = $self->get_assignment("",$stud,$asn_name);

       	   # Set up directories under assignment and grade
       	   $asn->{'Ungraded Dir'} = "$self->{'Root Dir'}/students/$stud_disk_name/ungraded";
       	   $asn->{'Graded Dir'} = "$self->{'Root Dir'}/students/$stud_disk_name/graded";
       	   $asn->regrade();
       }
       undef $asn;
   }
}

sub ungrade {
   my ($self,$stud_names,$asn_names) = @_;

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   # Get class names and set up dummy student object
   foreach $asn_name (@{$asn_names}) {
       foreach $stud_name (@{$stud_names}) {
           my $stud_obj = $self->get_member("",$stud_name);
           my $asn = $self->get_assignment("",$stud_obj,$asn_name);
           $asn->ungrade();
       }
   }
}

#########################################
=head2 view_scores(\@stu,\@asn,$inst)

=over 4

=item Description
View scores for the given students
and assignments

=item Params
@stu: list of students

@asn: list of assignments

=item Returns
none

=back

=cut

sub view_scores {
   my ($self,$stud_names,$asn_names,$inst) = @_;
   my $tot_pts_rec = 0;
   my $tot_pts = 0;
   my @asn_files;
   my %asn_info = {};

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   # Grade ungraded assignments. 
   foreach $sname (@{$stud_names}) {
       my $stud = $self->get_member("",$sname);
       foreach $aname (@{$asn_names}) {
           my $asn = $self->get_assignment("",$stud,$aname);
           $asn->grade_ungraded();
       }
   } 

   # Get an associative array of assignment types
   foreach $asn_name (@{$asn_names}) {
       my $disk_name = CGI::escape($asn_name);
       my %info = ASSIGNMENT->get_info($self,$asn_name);
       $asn_info{$asn_name} = \%info;
   }

   my $hasTable = CN_UTILS::hasTables();
   # Loop on students and assignments
   my $detail = "<CENTER><H3>Details</H3></CENTER>\n";
   TEST->print_test_header('Scores');
   print "<CENTER><H4>$self->{'Name'}</H4></CENTER>$GLOBALS::HR\n";
   print "<CENTER><H3>Summary</H3></CENTER><P>\n";
   if ($hasTable) {
       print "<TABLE border=1 cellpadding=2 width=100%>";
       print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>Student Name\n";
       print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>Earned\n";
       print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>Possible\n";
   } else {
       printf("<PRE>%-20s%10s%10s",'Student Name','Earned','Possible');
   }
   my $tabstr = "Student Names";
   foreach $asn_name (@{$asn_names}) {
       my $pts = $asn_info{$asn_name}{'TP'};
       my $asn_type = $asn_info{$asn_name}{'Assignment Type'};
       if ($asn_type =~ /EVAL/) {
         $pts = 0;
       }
       if ($hasTable) {
           print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>$asn_name($pts pts)\n";
       } else {
           printf("%15s(%s pts)",$asn_name,$pts);
       }
       $tabstr .= "\t$asn_name($pts pts)"; 
   }
   if ($hasTable) {
       print "<TR BGCOLOR='#FFFFFF'>\n";
   } else {
       print "<BR>\n";
   }
   $tabstr .= "\n";
   foreach $stud_name (@{$stud_names}) {
       $detail .= "<HR><CENTER><H5>$stud_name</H5></CENTER>\n";
       if ($hasTable) {
           print "<TD ALIGN=LEFT>$stud_name\n";
       } else {
           printf("%-20s",$stud_name);
       }
       $tabstr .= "$stud_name";
       my $line = '';
       my $pts;
       foreach $asn_name (@{$asn_names}) {
           my $asn_type = $asn_info{$asn_name}{'Assignment Type'};
           my @scores = ($asn_type)->get_score($self,$asn_name,$stud_name);
           $pts = $scores[2];
           if ($pts =~ /(\?|\*|\-|\#)/) {
             if ($pts =~ /(\d+)\?/) {
                 $pts = $1;
             } else {
                 $pts = 0;
             }
           }
       	   if ($hasTable) {
               $line .= "<TD ALIGN=RIGHT>$scores[2]\n";
           } else {
               $line .= sprintf("%15s","$scores[2]");
           }
           $tabstr .= "\t$scores[2]"; 
       	   $tot_pts += $scores[1];
       	   $tot_pts_rec += $pts;
           $detail .= "$scores[0]\n";
       }
       $tabstr .= "\n";
       if ($hasTable) {
           print "<TD ALIGN=RIGHT>$tot_pts_rec<TD ALIGN=RIGHT>$tot_pts\n";
           print "$line<TR BGCOLOR='#FFFFFF'>\n";
       } else {
           printf("%10s%10s%s<BR>\n",$tot_pts_rec,$tot_pts,$line);
       }
       $tot_pts = $tot_pts_rec = 0;
   }
   if ($hasTable) {
       print "</TABLE>\n";
   } else {
       print "</PRE><BR>\n";
   }
   print "- = not seen or seen but not submitted<BR>";
   print "* = submitted but awaiting due date<BR>";
   print "? = requires instructor grading<BR>";
   print "# = non-scored evaluation or survey<BR>";
   my $script = "gradebook";                                          
   if ($inst->{'Member Type'} =~ /student/) {                         
        $script = "student";                                          
   }                                                                  
   print <<"FORM";                                                    
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/$script>               
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">         
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">   
<INPUT TYPE=hidden NAME=cn_option VALUE="Mail Table">                 
<INPUT TYPE=hidden NAME=table VALUE="$tabstr">                        
<CENTER>                                                              
<img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif"><P>       
</CENTER>                                                             
<BLOCKQUOTE>                                                          
You may mail a text version of the summary table to yourself. Columns 
will be separated by tabs making the file suitable for importing into 
a spreadsheet.                                                        
</BLOCKQUOTE>                                                         
<P>                                                                   
<CENTER>                                                              
<INPUT TYPE=submit NAME=mailTable VALUE="Mail">                       
</CENTER>                                                             
FORM
   print $detail;
   print "</BODY>\n</HTML>\n";
   exit(0);
}

sub last_access {
    my ($self) = @_;
    my $msg = '';
    my $forum = CN_UTILS::get_disk_name($self->{'Name'});
    $file = "$GLOBALS::FORUM_DIR/$forum/topics";
    if (-e $file) {
        my $dt = CN_UTILS::getTime($file);
        $msg .= "Last Discuss topic added on $dt<BR>";
    }
    my $file = "$self->{'Root Dir'}/chat";
    if (-e $file) {
        my $dt = CN_UTILS::getTime($file);
        $msg .= "Last Chat on $dt<BR>";
    }
    return $msg;
}

#########################################
=head2 view_assignments(\@stu,\@asn,$inst,$op)

=over 4

=item Description
View scores for the given students
and assignments

=item Params
@stu: list of students
@asn: list of assignments
$inst: 'instructor' or 'student'
$op: 'add' or 'delete'

=item Returns
none

=back

=cut

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

sub submit_delete_changes {
   my ($self,$query) = @_;

   my @deletions = $query->param('assignments');
   foreach (@deletions) {
       my ($sname,$type,$aname) = split(/\//);
       $aname = CGI::unescape($aname);
       my $stud = $self->get_member("",$sname);
       my $asn = ($type)->new($query,$self,$stud,$aname);
       if ($asn->get_status() eq 'graded') {
           unlink "$asn->{'Graded Dir'}/$asn->{'Student File'}";
       } else {
           unlink "$asn->{'Ungraded Dir'}/$asn->{'Student File'}";
       }
   }
}

sub submit_add_changes {
   my ($self,$query) = @_;

   my @adds = $query->param('assignments');
   foreach (@adds) {
       my ($sname,$type,$aname) = split(/\//);
       $aname = CGI::unescape($aname);
       my $stud = $self->get_member("",$sname);
       my $asn = ($type)->new($query,$self,$stud,$aname);
       $asn->get_new_form('student','submit');
   }
}

sub print_reg_options {
    my ($self,$inst) = @_;
    
    my @ck = (undef,undef,undef);
    $ck[$self->{'Verify Enrollment'}] = 'CHECKED';
    my $expire = $self->{'Expiration Month'};
    my $showcomm = $self->{'ShowComm'};
    if ($showcomm =~ /no/) {
       $showcomm = "";
    } else {
       $showcomm = "CHECKED";
    }
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
<INPUT TYPE=check NAME='ShowComm' $showcomm> Show Communcation 
Options on Student Menu
 <h3>For Registered Iowa State University Classes 
only</h3> </center>
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

sub print_renewal {
    my ($self,$inst) = @_;
    
   # Must be owner
   if ($inst->{'Priv'} ne 'owner') {
      ERROR::user_error($ERROR::NOPERM);
   }

   # Get the form;
   CN_UTILS::print_cn_header("Renew Class");
   print <<"HTML";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Renew">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3></CENTER>
The renew option will <B>delete</B> the following items:
<UL>
<LI>All <B>student</B> records
<LI><B>Chat</B> comments
<LI><B>Discussions</B>
</UL>
<P>
However, all <B>instructor</B> records and <B>assignments</B> will
remain unchanged.
<P>
<CENTER>
<H4>
<INPUT TYPE=submit Value=Renew>
<BR> 
<INPUT TYPE=submit name=memback VALUE="Members Menu">
</H4>
</CENTER>

HTML
   CN_UTILS::print_cn_footer("renew.html");
}

sub renew {
    my ($self) = @_;
    system("rm -f $self->{'Root Dir'}/admin/members/students/*");
    system("rm -f $self->{'Root Dir'}/admin/members/requests/*");
    system("rm -f $self->{'Root Dir'}/admin/member_lists/students");
    system("rm -rf $self->{'Root Dir'}/students/*");
    system("rm -f $self->{'Root Dir'}/chat");
    system("rm -f $GLOBALS::FORUM_DIR/$self->{'Disk Name'}/topics/*");
    system("rm -f $GLOBALS::FORUM_DIR/$self->{'Disk Name'}/responses/*");
}

#########################################
=head2 graph(\@stu,\@asn)

=over 4

=item Description
Graph a histogram of scores for given students and assignments

=item Params
@stu: list of students

@asn: list of assignments

=item Returns
none

=back

=cut

sub histogram {
   my ($self,$stud_names,$asn_names,$inst) = @_;
   my $query = $self->{'Query'};
   my $asn_info = {};

   # produce histogram of scores across assignments
   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   
   # Get an associative array of assignment types
   foreach $asn_name (@{$asn_names}) {
       my $disk_name = CGI::escape($asn_name);
       my %info = ASSIGNMENT->get_info($self,$asn_name);
       $asn_info{$asn_name} = \%info;
   }
   my %tot = {};
   my $tp;
   foreach $stud_name (@{$stud_names}) {
       my $score = 0;
       $tp = 0;
       foreach $asn_name (@{$asn_names}) {
           my $asn_type = $asn_info{$asn_name}{'Assignment Type'};
           my @scores = ($asn_type)->get_score($self,$asn_name,$stud_name);
           my $sc = $scores[2];
           if ($sc =~ /(\?|\*|\-|\#)/) {
             if ($sc =~ /(\d+)\?/) {
                 $sc = $1;
             } else {
                 $sc = 0;
             }
           }
       	   $score += $sc;
           $tp += $scores[1];
       }
       $tot{$score}++;
   }
   my $fname = "$$.dat";
   open(DATA,">$fname");
   my $max = 0;
   foreach $v (keys %tot) {
       my $n = $tot{$v}; 
       print DATA "$v $n\n";
       ($n > $max) and $max = $n;
   }
   close(DATA);
   my @parms = (
'set terminal pbm color small',
'set data style impulse',
'set size .5,.5',
'set boxwidth .1',
'set xlabel "Score"',
'set ylabel "Count"',
'set nolabel',
"set xrange [0:$tp]",
"set yrange [0:$max]",
"set ytics 0,1,$max",
'set format x "%3.0f"',
'set format y "%3.0f"',
'set title "Score Distribution"',
"plot '$fname' title '' with impulse 3");
my $gname = CN_UTILS::plot($fname,\@parms);
unlink $fname;
my $filename = $gname;
$filename =~ /(\d+.gif)/;
$filename = "/local/classnet/html/tmpgifs/$1";

   TEST->print_test_header('Histogram');
   print <<"HISTOGRAM";
<CENTER><H4>$self->{'Name'}</H4></CENTER>$GLOBALS::HR
<CENTER><H3>Histogram of Scores</H3>
<IMG BORDER=2 SRC=\"$gname\"></CENTER>
<P>
<CENTER>Click on Publish to make available to students<BR>
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/gradebook>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME=Filename VALUE="$filename">
<INPUT TYPE=hidden NAME=cn_option VALUE="Publish Histogram">
<INPUT TYPE=SUBMIT VALUE="Publish">
</CENTER>
</FORM>
HISTOGRAM
   print "<P>For assignments:<BR>\n<UL>\n";
   foreach $asn_name (@{$asn_names}) {
       print "<LI>$asn_name\n";
   }
   print "</UL>\n";
   if ($file_name ne '') {
       print "<P>This histogram of total class scores is viewable by students.<P>";
   }
   print "</BODY>\n</HTML>\n";
   exit(0);
}
1;
