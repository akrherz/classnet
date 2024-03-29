package ASSIGNMENT;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader);

#########
=head1 ASSIGNMENT

=head1 Methods:

=cut
#########

require CGI;
require ERROR;

#########################################
=head2 new($query, $cls, $member, $asn_name)

=over 4

=item Description

=item Params
$query: CGI query object

$cls: CLASS object

$mem: MEMBER object

$asn_name: Assignment Name (optional)

=item Returns
ASSIGNMENT object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $asn_name) = @_;
   my $self = {};
   bless $self, $class;

   $self->{'Name'} = (defined $asn_name)? $asn_name:$query->param('Assignment Name');
   $self->{'Disk Name'} = CN_UTILS::get_disk_name($self->{'Name'});
   $self->{'Form Root'} = "$cls->{'Root Dir'}/assignments/$self->{'Disk Name'}";
   # if the assignment is published, it will be in the main assignment dir
   # if it is not published, it will be in the assignments/.develop dir
   if (-e $self->{'Form Root'}) {
       $self->{'Dev Root'} = $self->{'Form Root'};
   } else {
       $self->{'Dev Root'} = "$cls->{'Root Dir'}/assignments/.develop/$self->{'Disk Name'}";
   }
   
   # If student, set up assignment dirs
   if ($member and ($member->{'Member Type'} eq 'student')) {
       $self->{'Ungraded Dir'} = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}/ungraded";
       $self->{'Graded Dir'} = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}/graded";
       $self->{'Java Dir'} = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}/java/$self->{'Disk Name'}"; 
       $self->{'Dialog Dir'} = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}/dialog"; 
   }

   $self->{'Student File'} = $self->{'Disk Name'};
   # Note type of editor
   $self->{'Editor Type'} = 'TESTEDITOR';

   # Store object ptrs
   $self->{'Query'} = $query;
   $self->{'Class'} = $cls;
   $self->{'Member'} = $member;

   return $self;
}

__END__

#########################################
=head2 get_info($cls,$asn_name)

=over 4

=item Description
Retrieve the header information for an assignment

=item Params
$cls: the CLASS object

$asn_name: Name of assignment

=item Returns
An assignment object

=back

=cut

sub get_info {
    my ($cls,$asn_name) = @_;

   $disk_name = CN_UTILS::get_disk_name($asn_name);
   $root = "$cls->{'Root Dir'}/assignments/$disk_name/options";
   # if the assignment is published, it will be in the main assignment dir
   # if it is not published, it will be in the assignments/.develop dir
   if (!(-e $root)) {
       $root = "$cls->{'Root Dir'}/assignments/.develop/$disk_name/options";
   }
   if (-e $root) {
       $/ = "\n";
       open(ASN,"<$root") or
            ERROR::system_error('ASSIGNMENT','get_info','open',$root);
       my $header = <ASN>;
       close ASN;
       return ASSIGNMENT->unpack_assign_header($header);
   } else {
       return '';
   }
}

#########################################
=head2 read()

=over 4

=item Description
Read assignment data from file

=item Params
none

=item Returns
%params: associative list of test values
or undef if wrong format
=back

=cut

sub read {
    my ($self) = @_;
    my $header = $self->get_assign_header();
    return (ref($self))->unpack_assign_header($header); }

#########################################
=head2 write(%params)

=over 4

=item Description
Write the header to the file using %params

=item Params
%params: assignment parameters to write

=item Returns
none

=back

=cut

sub write {
    my ($self,%params) = @_;
    my $hdr = (ref($self))->pack_assign_header(%params);
    $self->put_assign_header($hdr);
}


#########################################
=head2 create()

=over 4

=item Description
Create an assignment

=item Params
none

=item Returns
none

=back

=cut

sub create {
    my ($self) = @_;
    # if the assignment already exists report error
    if (-e $self->{'Dev Root'}) {
        ERROR::user_error($ERROR::ASSIGNEX,$self->{'Name'}); 
    }
    # create .develop directory if not already there
    $cls = $self->{'Class'};
    $dev_dir = "$cls->{'Root Dir'}/assignments/.develop";
    if (!(-e $dev_dir)) {
        mkdir($dev_dir,0700);
    }
    $asn_dir = $self->{'Dev Root'};
    mkdir($asn_dir,0700) or
        ERROR::system_error('ASSIGNMENT','create','mkdir',$asn_dir);
}

#########################################
=head2 print_listbox($cls,$which)

=over 4

=item Description
print a listbox of available assignments

=item Params
$cls: The class for which assignments are desired

$which: 'all' if both published and unpublished assignments
are desired

$mult: 'MULTIPLE' if multiple select box is desired

=item Returns
none

=back

=cut

sub print_listbox {
    my ($cls,$which,$mult) = @_;
    opendir(ASNDIR,"$cls->{'Root Dir'}/assignments");
    @asnfiles = grep(!/^\.\.?/,readdir(ASNDIR));
    closedir(ASNDIR);
    $dev_dir = "$cls->{'Root Dir'}/assignments/.develop";
    if (($which eq 'all') && (-e $dev_dir)) {
        opendir(DEVDIR,$dev_dir);
        push(@asnfiles,grep(!/^\.\.?/,readdir(DEVDIR)));
        closedir(DEVDIR);
    }
    foreach $i (0..$#asnfiles) {
       $asnfiles[$i] = CGI::unescape($asnfiles[$i]);
    }
    print "<SELECT $mult SIZE=5 NAME=\"Assignment Name\">\n";
    foreach $assign_name (sort {uc($a) cmp uc($b)} @asnfiles) {
        print qq|<OPTION> $assign_name\n|;
    }
    print "</SELECT>";
}

#########################################
=head2 print_menu()

=over 4

=item Description
print the assignment menu

=item Params
$cls: The class object for which assignments are desired

$inst: The instructor object for authorization

=item Returns
none

=back

=cut

sub print_menu {
    my ($cls,$inst) = @_;
    CN_UTILS::print_cn_header("Assignments");
    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SERVER_ROOT/cgi-bin/assignments>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3>
FORM
    &print_listbox($cls,'all');
    print <<"FORM";
<P>
<H4>
<INPUT TYPE=submit NAME=cn_option VALUE=Edit>
<INPUT TYPE=submit NAME=cn_option VALUE=Delete>
<INPUT TYPE=submit NAME=cn_option VALUE=Add>
<INPUT TYPE=submit NAME=cn_option VALUE=Mail>
<INPUT TYPE=submit NAME=cn_option VALUE=Upload>
<BR>
<INPUT TYPE=submit NAME=cn_option VALUE="Instructor Menu">
</H4>
</CENTER>
FORM
    CN_UTILS::print_cn_footer("assignments.html");
}

#########################################
=head2 print_upload($cls,$inst)

=over 4

=item Description
print the assignment menu

=item Params
$cls: The class object for which assignments are desired

$inst: The instructor object for authorization

=item Returns
none

=back

=cut

sub print_upload {
    my ($self,$cls,$inst) = @_;
    CN_UTILS::print_cn_header("Upload File");
    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SERVER_ROOT/cgi-bin/assignments 
ENCTYPE="multipart/form-data"> <INPUT TYPE=hidden NAME="Class Name" 
VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="cn_option" VALUE="Perform Upload">
<CENTER><H3>$self->{'Name'}</H3></CENTER>
<table align="center" width="50%">
<tr>
<td>
Enter a filename to upload. When you refer to it in your assignment, use 
only the filename, not the local path information.
<p>
Example:<br>
<b>Filename:</b> D:\\class\\images\\test.gif<br>
<b>HTML:</b>&lt;img src="test.gif"&gt;
</td>
</tr>
</table>
<CENTER>
<H4>
<b>FileName:</b><INPUT TYPE=file NAME="FileName" SIZE=40>
<BR>
<INPUT TYPE=submit Value="Upload"> <INPUT TYPE=reset>
<BR>
<INPUT TYPE=submit NAME=back Value="Assignments Menu"> 
</H4>
</CENTER>
FORM
    CN_UTILS::print_cn_footer("assignments.html");
}

#########################################
=head2 delete()

=over 4

=item Description
Delete this assignment
=item Params
none

=item Returns
none

=back

=cut

sub delete {
    my ($self) = @_;
    system "rm -rf $self->{'Dev Root'}";
    #delete student assignments?
}

#########################################
=head2 print_add_form($cls,$inst)

=over 4

=item Description
Print the form to add assignments.

=item Params
$cls: CLASS object

$inst: INSTRUCTOR object

=back

=cut

sub print_add_form {
   my ($cls, $inst) = @_;

   # Get the form;
   CN_UTILS::print_cn_header("Add Assignment");
   print "<CENTER><H3>$cls->{'Name'}</H3></CENTER>\n";
   print <<"HTML";
<FORM ENCTYPE="multipart/form-data" METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/assignments>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Add Assign">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<BLOCKQUOTE>
Enter the name of the assignment and select its type. You may optionally specify an
input file. Click on <B>Add</B> when done.
<PRE>
HTML
print "<B>       Type:</B> ";
ASSIGNMENT::print_types('TEST');
    print <<"HTML";
<B>       Name:</B> <INPUT TYPE=text NAME="Assignment Name" SIZE=15 MAXLENGTH=15>
</PRE>
<P>
<CENTER><H4>
<img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif">
Publish Options</H4></CENTER>
<MENU>
<INPUT TYPE=radio NAME=publish VALUE="P">Make available to
students immediately(publish) <BR>
<INPUT TYPE=radio NAME=publish VALUE="N" CHECKED>Put in development folder on
ClassNet and publish later
</MENU>
<CENTER><H4>Loading from an Initial File(optional)</H4></CENTER>
If you have <a
href="/help/maketest.html">prepared a
file</a> in a Web directory or on your local computer, you may specify
its name below and load it into ClassNet.
<UL>
<LI>If the file is on your own computer, fill in the Initial File field.
<LI>If the file is in a Web-accessible directory, fill in Initial URL field.
<LI>Leave both blank if you don't have a file.
<LI>Fill in only one of the two.
</UL>
<PRE>
<B>Initial URL: </B> <INPUT TYPE=text NAME="Initial URL" SIZE=40>
<B>Initial File:</B> <INPUT TYPE=file NAME="Initial File" SIZE=40>
</PRE>
</BLOCKQUOTE>
<CENTER>
<H4>
<INPUT TYPE=submit Value=Add> <INPUT TYPE=reset>
<BR>
<INPUT TYPE=submit NAME=back Value="Assignments Menu"> 
</CENTER>
</H4>
</FORM>
<P>
HTML
   CN_UTILS::print_cn_footer("add_assignment.html");
}

#########################################
=head2 publish()

=over 4

=item Description
Publish assignment by moving it from .develop to
assignments directory if not already there

=item Params
none

=back

=cut

sub publish {
    my ($self) = @_;
    if ($self->{'Dev Root'} =~ /.develop/) {
        rename($self->{'Dev Root'},$self->{'Form Root'});
        $self->{'Dev Root'} = $self->{'Form Root'};
    }
}

#########################################
=head2 unpublish()

=over 4

=item Description
Unpublish assignment by moving it from assignments directory
to .develop directory if not already there

=item Params
none

=back

=cut

sub unpublish {
    my ($self) = @_;
    if (!($self->{'Dev Root'} =~ /.develop/)) {
        my $cls = $self->{'Class'};
        my $dir = "$cls->{'Root Dir'}/assignments/.develop/$self->{'Disk Name'}";
        rename($self->{'Dev Root'},$dir);
        $self->{'Dev Root'} = $dir;
    }
}

#########################################
=head2 print_types()

=over 4

=item Description
Print the Popup box of types

=item Params
none

=back

=cut

sub print_types {
    my ($name) = shift;
    @types = split(/,/,$GLOBALS::ASSIGNMENT_TYPES);
    print "<SELECT NAME=\"Assignment Type\">\n";
    foreach (sort @types) {
        print '<OPTION ';
        if ($_ eq $name) {
           print "<OPTION SELECTED>$_\n";
        } else {
           print "<OPTION>$_\n";;
        }
    }
    print "</SELECT>\n";
}

#########################################
=head2 get_assign_header()

=over 4

=item Description
Returns the assignment header

=item Params
none

=item Returns
One line header string "<CN_ASSIGN ...>"

=back

=cut

sub get_assign_header {
    my ($self) = @_;
    my (%params, $adata);

    # Set input record separator and read the file
    $/ = "\n";

    $fname = "$self->{'Dev Root'}/options";
    open(ASN,"<$fname") or
        ERROR::system_error('ASSIGNMENT','read','open',$fname);
    $adata = <ASN>;
    close(ASN);
    return $adata;    
}

#########################################
=head2 put_assign_header($hdr)

=over 4

=item Description
Write assignment data to file

=item Params
$hdr: Header for assignment

=item Returns
none

=back

=cut

sub put_assign_header {
    my ($self,$hdr) = @_;
    $fname = "$self->{'Dev Root'}/options";
    open(ASN,">$fname") or
        ERROR::system_error('ASSIGNMENT','put_assign_header','open',$fname);
    print ASN "$hdr\n";
    close(ASN);
}

#########################################
=head2 pack_assign_header()

=over 4

=item Description
Pack an assignment header

=item Params
%params: associative array of test values

=item Returns
One line header string "<CN_ASSIGN ...>"

=back

=cut

sub pack_assign_header {
    my ($class,%params) = @_;
    my $hdr = "<CN_ASSIGN ";
    $hdr .= "TYPE=$params{'Assignment Type'} ";
    ($params{'DUE'}) and $hdr .= "DUE=$params{'DUE'} ";
    ($params{'PASSWORD'}) and $hdr .= "PASSWORD=\"$params{'PASSWORD'}\" ";
    $hdr .= ($params{'TP'})? "TP=$params{'TP'} ":"TP=0 ";
    $hdr .= ($params{'VIEW'})? "OPT=VIEW":"OPT=NOVIEW";
    return $hdr . ' >';
}

#########################################
=head2 unpack_assign_header()

=over 4

=item Description
Unpack an assignment header

=item Params
$header: The one line header string "<CN_ASSIGN ...>"

=item Returns
One element associative array of option values: $assign_info{'OPT'}

=back

=cut

sub unpack_assign_header {
   my ($class,$header) = @_;
   my %assign_info = {};

   # Passing the wrong header?
   ($header =~ m/<\s*CN_ASSIGN\s*/i) or return undef;

   # Get rid of any line separators and chop >
   $/="";
   chomp $header;
   chop $header;
   
   # TYPE default
   $assign_info{'Assignment Type'} = 'TEST';

   # Parse out info
   (($header =~ m/\sTYPE="([^"]*)/i) or ($header =~m/\sTYPE=(\S*)/i)) and
       $assign_info{'Assignment Type'} = "\U$1\E";
   (($header =~ m/\sOPT="([^"]*)/i) or ($header =~ m/\sOPT=(\S*)/i)) and
       $assign_info{'OPT'} = $1;
   (($header =~ m/\sDUE="([^"]*)/i) or ($header =~m/\sDUE=(\S*)/i)) and
       $assign_info{'DUE'} = $1;
   $assign_info{'TP'} = (($header =~ m/\sTP="([^"]*)/i) or 
                         ($header =~ m/\sTP=(\S*)/i))? $1:0;
   (($header =~ m/\sPASSWORD="([^"]*)/i) or ($header =~m/\sPASSWORD=(\S*)/i)) and
       $assign_info{'PASSWORD'} = $1;
   # Add any defaults
   $assign_info{'VIEW'} = ($assign_info{'OPT'} =~ m/NOVIEW/i) ? 0 : 1;

   return %assign_info;
}

#########################################
=head2 edit()

=over 4

=item Description
Create an editor and open it

=item Params
none

=item Returns
none

=back

=cut

sub edit {
    my ($self) = @_;
    $editor = $self->{'Editor Type'}->new($self);
    $editor->open();
}

#########################################
=head2 grade_ungraded()

=over 4

=item Description
Try to grade ungraded assignments

=item Params
none

=item Returns
none

=back

=cut

sub grade_ungraded {
   my ($self) = @_;

   # default is to grade if it is ungraded
   if ($self->get_status() eq 'ungraded') {
       $self->grade();
   }
}

#########################################
=head2 submit()

=over 4

=item Description
Student is requesting to submit assignment

=item Params
none

=item Returns
none

=back

=cut

sub submit {
   my $self = shift;

   # Store the query unless it has been graded
   if ($self->get_status() eq 'ungraded') {
       $self->write_assign_query();
   }
   else {
       ERROR::user_error($ERROR::GRADED);
   }

   # Attempt to grade any ungraded assigns for this student
   # $self->grade_ungraded();
}

#########################################
=head2 write_assign_query()

=over 4

=item Description
Store submitted query in ungraded directory

=item Params
none

=item Returns
none

=back

=cut

sub write_assign_query {
    # abstract stub
}

#########################################
=head2 grade()

=over 4

=item Description
Grade the assignments

=item Params
none

=item Returns
none

=back

=cut

sub grade {
    # abstract stub
}

#########################################
=head2 ungrade()

=over 4

=item Description
Move a graded assignment to the ungraded directory

=item Params
none

=item Returns
none

=back

=cut

sub ungrade {
    my ($self) = @_;
    my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
    if (-e $fname) {
        rename($fname,"$self->{'Ungraded Dir'}/$self->{'Student File'}");
    } 
}

#########################################
=head2 regrade()

=over 4

=item Description
Grade this assignment again

=item Params
none

=item Returns
none

=back

=cut

sub regrade {
    my ($self) = @_;
    # make sure an assignment exists, then grade
    ($self->get_status()) and $self->grade(); 
}

#########################################
=head2 get_status()

=over 4

=item Description
Return whether graded, ungraded or non-existent

=item Params
none

=item Returns
'graded','ungraded' or 0

=back

=cut

sub get_status {

   my $self = shift;

   my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}"; 
   if (-e $fname) {
       return 'graded';
   }
   
   $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}"; 
   if (-e $fname) {
       # check to see if it is an old unsubmitted assignment
       #$/ = "\n";
       #open(ASN,"<$fname");
       #my $header = <ASN>;
       #close ASN;
       #if ($header =~ / SUBMIT=0/) {
       #    $self->{'SEEN'} = CN_UTILS::getTime($fname);
       #    if (-M _ > 1) {
       #        unlink $fname;
       #        return 0;
       #    }
       #}
       return 'ungraded';
   }
   return 0;

}

sub source {
    my ($self) = @_;
    return $self->get_assign_header();
}

sub upload {
    my ($self,$hfile) = @_;
    my ($header);

    if (!defined $hfile) { 
        ERROR::user_error($ERROR::NOTDONE,"find file <B>$url</B>");
        exit(0);
    }
    
    $hfile =~ s/[^<]*(<CN_ASSIGN TYPE=\w+[^>]*>)/eval { $header = $1; ''}/e;
    my %params = (ref($self))->unpack_assign_header($header);
    if (!defined %params) {
        ERROR::user_error($ERROR::NOTDONE,"upload assignment information: $header");
        exit(0);
    }
    my $tp = ref($self);
    if (!("\U$params{'Assignment Type'}\E" eq $tp)) {
        ERROR::user_error($ERROR::NOTDONE,"upload. Expecting $tp instead of $params{'Assignment Type'}");
        exit(0);
    }
    $self->create();
    $self->write(%params);
    return $hfile;
}

sub get_names {
    my ($self,$status) = @_;
    my @names = ($self->{'Name'});
    if ($self->get_status()) {
        ($status eq 'existing')? @names:();
    } else {
        ($status eq 'existing')? ():@names;
    }
}

sub prompt_stats {
    my ($self,$cls,$inst,$stud_names) = @_;
   # Get the form;
   $snames = join(";",@{$stud_names});
   CN_UTILS::print_cn_header("Statistics");
   print "<CENTER><H3>$cls->{'Name'}</H3></CENTER>\n";
   print <<"HTML";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/gradebook>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Statistics">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME=Students VALUE="$snames">
<BLOCKQUOTE>
<CENTER><img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif"></CENTER>
You may categorize statistics by one or more questions.  For example, 
if question 3 asks a student to specify year of college
(i.e. freshman, sophomore, junior or senior), categorizing on question
3 would generate four tables, one for each year.
<P>
Follow these simple guidelines to complete your statistical analysis:
<UL>
<LI>Enter the number of the question below. To categorize by multiple questions, separate question numbers  by commas (e.g. 3,8,1)
<LI>Only CHOICE, OPTION, LIST and LIKERT questions my be used for
categorization.
<LI>Leave the blank empty if no categorization is desired.
</UL>
<P>
<CENTER>
<B>Question Categories </B>
<INPUT TYPE="text" NAME="Categories">
<P>
<INPUT TYPE=submit VALUE="Submit">
</CENTER>
HTML
   CN_UTILS::print_cn_footer();
   exit(0);
}

sub print_stats {
    my ($self,$stud_names) = @_;
    my %stats = {};
    my %tot = {};
    my $cls = $self->{'Class'};
    foreach $sname (@{$stud_names}) {
       my $dname = CN_UTILS::get_disk_name($sname);
       $self->{'Ungraded Dir'} = "$cls->{'Root Dir'}/students/$dname/ungraded";
       $self->{'Graded Dir'} = "$cls->{'Root Dir'}/students/$dname/graded";
       $self->grade_ungraded();
       $self->get_stats(\%stats,\%tot);
    }
    $self->format_stats(\%stats,\%tot);
}

sub get_stats {
    my ($self,$stats) = @_;
    return 0;
}

sub format_stats {
    my ($self,$stats) = @_;
    '';
}

sub mail_raw_data {
    my ($self,$stud_names) = @_;
    my $inst = $self->{'Member'};
    my $cls = $self->{'Class'};
    my $body = '';
    foreach $sname (@{$stud_names}) {
       my $dname = CN_UTILS::get_disk_name($sname);
       $self->{'Ungraded Dir'} = "$cls->{'Root Dir'}/students/$dname/ungraded";
       $self->{'Graded Dir'} = "$cls->{'Root Dir'}/students/$dname/graded";
       $self->{'Java Dir'} = "$cls->{'Root Dir'}/students/$dname/java/$self->{'Disk Name'}";
       $self->{'Dialog Dir'} = "$cls->{'Root Dir'}/students/$dname/dialog";
       $body .= $self->format_raw_data($sname);
    }
    CN_UTILS::mail($inst->{'Email Address'},"Raw Data for $self->{'Name'}",$body);
}

sub format_raw_data {
    my ($self) = @_;
    '';
}

sub verify {
    my ($self) = @_;
    my $stu = $self->{'Member'};
    my $cls = $self->{'Class'};
    CN_UTILS::print_cn_header("Password Required");

    print <<"FORM";   
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/student>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$stu->{'Ticket'}">
<INPUT TYPE=hidden NAME=cn_option VALUE="Verify">
<CENTER>
A password is required to complete this assignment. Please enter below:<P>
<INPUT TYPE=password NAME=proctor VALUE="" SIZE=16><P>
<INPUT TYPE=submit VALUE="Verify">
</CENTER>
FORM
   CN_UTILS::print_cn_footer();
   exit(0);
}

# abstract method for extra assignment fields
sub get_extra_fields {
    my ($self) = @_;
    ''
}

sub put_extra_fields {
    my ($self,$query) = @_;
}

1;
