require CN_UTILS;

package CGI;
# CHANGE THIS VARIABLE FOR YOUR OPERATING SYSTEM
$OS = 'UNIX';
# $OS = 'MACINTOSH';
# $OS = 'WINDOWS';
# $OS = 'NT';
# $OS = 'VMS';

# Some OS logic.  Binary mode enabled on DOS, NT and VMS
$needs_binmode = $OS=~/WINDOWS|NT|VMS/;

sub new {
    my($class,$filehandle) = @_;
    my($IN);
    if ($filehandle) {
        my($package) = caller;
        # force into caller's package if necessary
        $IN = $filehandle=~/[':]/ ? $filehandle : "$package\:\:$filehandle"; 
    }
    my $self = {};
    bless $self,$class;
    $self->initialize($IN);
    return $self;
}

sub initialize {
    my($self,$filehandle) = @_;
    my($query_string,@lines);
    my($meth) = '';

    # if we get called more than once, we want to initialize
    # ourselves from the original query (which may be gone
    # if it was read from STDIN originally.)
    if (@QUERY_PARAM && !$filehandle) {

        $self->{'.init'}++;     # flag we've been inited
        foreach (@QUERY_PARAM) {
            $self->add_parameter($_);
            $self->{$_}=$QUERY_PARAM{$_};
        }
        return;

    } else {

        $meth=$ENV{'REQUEST_METHOD'} if defined($ENV{'REQUEST_METHOD'});

        # If filehandle is defined, then read parameters
        # from it.
        if ($filehandle) {
            binmode($filehandle) if $needs_binmode;
            chomp(@lines = <$filehandle>);
            # massage back into standard format
            if ("@lines" =~ /=/) {
                $query_string=join("&",@lines);
            } else {
                $query_string=join("+",@lines);
            }   
    
            # If method is GET or HEAD, fetch the query from
            # the environment.

        } elsif ($meth=~/^(GET|HEAD)$/) {

            $query_string = $ENV{'QUERY_STRING'};

            # If the method is POST, fetch the query from standard
            # input.

        } elsif ($meth eq 'POST') {

            if ($ENV{'CONTENT_TYPE'}=~m|^multipart/form-data|) {
                my($boundary) = $ENV{'CONTENT_TYPE'}=~/boundary=(\S+)/;
                $self->read_multipart($boundary,$ENV{'CONTENT_LENGTH'});
            } else {
                $query_string ='';      # hack to avoid 'uninitialized variable' warnings
                read(STDIN,$query_string,$ENV{'CONTENT_LENGTH'}) 
                    if $ENV{'CONTENT_LENGTH'} > 0;
            }

            # If neither is set, assume we're being debugged offline.
            # Check the command line and then the standard input for data.
            # We use the shellwords package in order to behave the way that
            # UN*X programmers expect.
        } else {
            require "shellwords.pl";
            my($input,@words);

            if (@ARGV) {
                $input = join(" ",@ARGV);
            } else {
                print STDERR "(offline mode: enter name=value pairs on standard input)\n";
                chomp(@lines = <>); # remove newlines
                $input = join(" ",@lines);
            }

            # minimal handling of escape characters
            $input=~s/\\=/%3D/g;
            $input=~s/\\&/%26/g;

            @words = &shellwords($input);
            if ("@words"=~/=/) {
                $query_string = join('&',@words);
            } else {
                $query_string = join('+',@words);
            }
        }
    }
    
    # We now have the query string in hand.  We do slightly
    # different things for keyword lists and parameter lists.
    if ($query_string) {
        if ($query_string =~ /=/) {
            $self->parse_params($query_string);
        } else {
            $self->add_parameter('keywords');
            $self->{'keywords'} = [$self->parse_keywordlist($query_string)];
        }
    }

    # Special case.  Erase everything if there is a field named
    # .defaults.
    if ($self->param('.defaults')) {
        undef %{$self};
    }
    
    # flag that we've been inited
    $self->{'.init'}++ if $self->param;

    # Clear out our default submission button flag if present
    $self->delete('.submit');
    $self->save_request;
}

#### Method: remote_addr
# Return the IP addr of the remote host.
####
sub remote_addr {
    return $ENV{'REMOTE_ADDR'} || '127.0.0.1';
}

sub delete {
    my($self,$name) = @_;
    delete $self->{$name};
    @{$self->{'.parameters'}}=grep($_ ne $name,$self->param());
    return wantarray ? () : undef;
}

sub parse_params {
    my($self,$tosplit) = @_;
    my(@pairs) = split('&',$tosplit);
    my($param,$value);
    foreach (@pairs) {
        ($param,$value) = split('=');
        $param = &unescape($param);
        $value = &unescape($value);
        $self->add_parameter($param);
        push (@{$self->{$param}},$value);
    }
}

sub add_parameter {
    my($self,$param)=@_;
    push (@{$self->{'.parameters'}},$param) 
        unless defined($self->{$param});
}

sub all_parameters {
    my $self = shift;
    return () unless defined($self) && $self->{'.parameters'};
    return () unless @{$self->{'.parameters'}};
    return @{$self->{'.parameters'}};
}

sub param {
    my($self,@p) = @_;
    return $self->all_parameters unless @p;
    my($name,$value,@other);

    # For compatability between old calling style and use_named_parameters() style, 
    # we have to special case for a single parameter present.
    if (@p > 1) {
        ($name,$value,@other) = $self->rearrange([NAME,[DEFAULT,VALUE,VALUES]],@p);
        my(@values);

        if ($p[0]=~/^-/ || $self->use_named_parameters) {
            @values = ref($value) ? @{$value} : $value;
        } else {
            foreach ($value,@other) {
                push(@values,$_) if defined($_) && ($_ ne '');
            }
        }
        # If values is provided, then we set it.
        if (@values) {
            $self->add_parameter($name);
            $self->{$name}=[@values];
        }
    } else {
        $name = $p[0];
    }

    return () unless $self->{$name};
    return wantarray ? @{$self->{$name}} : $self->{$name}->[0];
}

sub rearrange {
    my($self,$order,@param) = @_;
    return ('') x $#$order unless @param;
    return @param unless (defined($param[0]) && $param[0]=~/^-/)
        || $self->use_named_parameters;

    my $i;
    for ($i=0;$i<@param;$i+=2) {
        $param[$i]=~s/^\-//;     # get rid of initial - if present
        $param[$i]=~tr/a-z/A-Z/; # parameters are upper case
    }
    
    my(%param) = @param;                # convert into associative array
    my(@return_array);
    
    my($key);
    foreach $key (@$order) {
        my($value) = '';
        # this is an awful hack to fix spurious warnings when the
        # -w switch is set.
        if (ref($key) && ref($key) eq 'ARRAY') {
            foreach (@$key) {
                $value = $param{$_} unless defined($value) && ($value ne '');
                delete $param{$_};
            }
        } else {
            $value = $param{$key};
        }
        delete $param{$key};
        push(@return_array,$value);
    }

    return (@return_array,$self->make_attributes(%param));
}

sub use_named_parameters {
    my($self,$use_named) = @_;
    return $self->{'.named'} unless defined ($use_named);

    # stupidity to avoid annoying warnings
    return $self->{'.named'}=$use_named;
}

sub make_attributes {
    my($self,%att) = @_;
    return () unless %att;
    my(@att);
    foreach (keys %att) {
        push(@att,qq/$_="$att{$_}"/);
    }
    return @att;
}

sub read_multipart {
    my($self,$boundary,$length) = @_;
    my($buffer) = new MultipartBuffer($boundary,$length);
    return unless $buffer;
    my(%header,$body);
    while (!$buffer->eof) {
        %header = $buffer->readHeader;
        # In beta1 it was "Content-disposition".  In beta2 it's "Content-Disposition"
        # Sheesh.
        my($key) = $header{'Content-disposition'} ? 'Content-disposition' : 'Content-Disposition';
        my($param)= $header{$key}=~/ name="([^\"]*)"/;

        # possible bug: our regular expression expects the filename= part to fall
        # at the end of the line.  Netscape doesn't escape quotation marks in file names!!!
        my($filename) = $header{$key}=~/ filename="(.*)"$/;

        # add this parameter to our list
        $self->add_parameter($param);

        # If no filename specified, then just read the data and assign it
        # to our parameter list.
        unless ($filename) {
            my($value) = $buffer->readBody;
            push(@{$self->{$param}},$value);
            next;
        }

        # If we get here, then we are dealing with a potentially large
        # uploaded form.  Save the data to a temporary file, then open
        # the file for reading.
        my($tmpfile) = new TempFile;
        open (OUT,">$tmpfile") || die "CGI open of $tmpfile: $!\n";
        chmod 0666,$tmpfile;    # make sure anyone can delete it.
        my $data;
        while ($data = $buffer->read) {
            print OUT $data;
        }
        close OUT;

        # Now create a new filehandle in the caller's namespace.
        # The name of this filehandle just happens to be identical
        # to the original filename (NOT the name of the temporary
        # file, which is hidden!)
        my($filehandle);
        if ($filename=~/^[a-zA-Z_]/) {
            my($frame,$cp)=(1);
            do { $cp = caller($frame++); } until $cp!~/^CGI/;
            $filehandle = "$cp\:\:$filename";
        } else {
            $filehandle = "\:\:$filename";
        }

        open($filehandle,$tmpfile) || die "CGI open of $tmpfile: $!\n";
        binmode($filehandle) if $CGI::needs_binmode;

        push(@{$self->{$param}},$filename);

        # Under Unix, it would be safe to let the temporary file
        # be deleted immediately.  However, I fear that other operating
        # systems are not so forgiving.  Therefore we save a reference
        # to the temporary file in the CGI object so that the file
        # isn't unlinked until the CGI object itself goes out of
        # scope.  This is a bit hacky, but it has the interesting side
        # effect that one can access the name of the tmpfile by
        # asking for $query->{$query->param('foo')}, where 'foo'
        # is the name of the file upload field.
        $self->{'.tmpfiles'}->{$filename}=$tmpfile;

    }

}

sub save_request {
    my($self) = @_;
    # We're going to play with the package globals now so that if we get called
    # again, we initialize ourselves in exactly the same way.  This allows
    # us to have several of these objects.
    @QUERY_PARAM = $self->param; # save list of parameters
    foreach (@QUERY_PARAM) {
        $QUERY_PARAM{$_}=$self->{$_};
    }
    
}

# unescape URL-encoded data
sub unescape {
    my($todecode) = @_;
    $todecode =~ tr/+/ /;       # pluses become spaces
    $todecode =~ s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
    return $todecode;
}

# URL-encode data
sub escape {
    my($toencode) = @_;
    $toencode=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
    return $toencode;
}

package CLASS;

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

sub exists {
   my $self = shift;
   (-e $self->{'Root Dir'});
}

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
<B>Exit your Browser completely</B> when finished. See help for details.
<BR><B>All information you view while using a ClassNet class is for 
class use only and may not be shared with individuals outside the 
class.</b>
<BR>If your name is not on the list, you need to 
<a href="$GLOBALS::SECURE_SERVER_ROOT/cgi-bin/get_stud_reg_form">Join the 
ClassNet class</a> before you can enter it.
</BLOCKQUOTE>
END_FORM
   CN_UTILS::print_cn_footer("get_login.html");
}

sub get_mem_names {
   my ($self, $mem_type) = @_;
   my @mem_names;

   if ($mem_type eq 'requests') {
       opendir(MEM_LIST,"$self->{'Root Dir'}/admin/members/requests") or
       	   ERROR::system_error("CLASS", "get_cls_mem_info",
                               "opendir $mem_type","$self->{'Root Dir'}:$!");
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

sub get_member {
   my ($self, $query, $uname) = @_;
   my $mem,$tkt;

   # Change Username to disk representation;

   if (!(defined $uname)) {
       # get the ticket filename from the query
       $tkt = $query->param('Ticket');
       my $ticketfile = "$GLOBALS::TICKET_DIR$tkt";
       my $cname = $self->{'Name'};
       if (-e $ticketfile) {
           (open(TICKET_FILE, "<$ticketfile")) or
         	   &ERROR::system_error("CLASS","get_member","Open",$ticketfile);
           @line = <TICKET_FILE>;
           close(TICKET_FILE);
           chomp(@line);
           $uname = $line[0];
       } else {
       	   &ERROR::user_error($ERROR::NOTICKET);
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
       	       &ERROR::user_error($ERROR::NOPERM);
       }
   }
   elsif ($mem_type eq 'requests') {
       &ERROR::user_error($ERROR::ENROLL);
   }
   else {
       &ERROR::user_error($ERROR::MEMBERNF,$uname);
   }

   $mem->{'Member Type'} = $mem_type;
   $mem->{'Ticket'} = $tkt;
   return $mem;  

}

sub mem_exists {

   my ($self, $disk_uname) = @_;

   # Enrolled student?
   my $fname = "$self->{'Root Dir'}/admin/members/students/" . $disk_uname;
   if (-e $fname) {
       return 'student';
   }

   # Requesting student?
   $fname = "$self->{'Root Dir'}/admin/members/requests/" . $disk_uname;
   return 'requests' if (-e $fname);

   # Instructor?
   $fname = "$self->{'Root Dir'}/admin/members/instructors/" . $disk_uname;
   (-e $fname) ? 'instructor' : "";
}

package CLASS;

sub get_uname {
   my ($self, $email) = @_;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   if (!(-e $fname)) {
       open(EFILE,">$fname") or
           &ERROR::system_error("CLASS","get_uname","create $fname",$email);
       flock(EFILE, $LOCK_EX);
       my @members = $self->get_mem_names('instructor');
       push(@members,$self->get_mem_names('student'));
       foreach $member (@members) {
           my $val = $self->get_email_addr($member);
           print EFILE "$val=$member\n";
       }
       flock(EFILE,$LOCK_UN);
       close(EFILE);
   }
   open(ELIST,"<$fname") or
       &ERROR::system_error("CLASS","get_uname","open $fname",$email);
   flock(ELIST, $LOCK_EX);
   my @list = <ELIST>;
   flock(ELIST, $LOCK_UN);
   close ELIST;
   chomp(@list);
   foreach $line (@list) {
       my ($key,$uname) = split(/=/,$line);
       $key = CN_UTILS::remove_spaces($key);
       if ($key eq $email) {
           return $uname;
       }
   }
   # not found so see if on request list
   my @req = $self->get_mem_names('requests');
   foreach $member (@req) {
       my $disk_uname = CN_UTILS::get_disk_name($member);
       my $fname = "$self->{'Root Dir'}/admin/members/requests/$disk_uname"; 
       open(REQ,"<$fname") or
           ERROR::user_error($ERROR::MEMBERNF,$uname);
       while (<REQ>) {
           chop;
           my ($name,$value) = split(/=/);
           if ($name eq 'Email Address') {
               if ($email eq $value) {
                   return '$requests';
               }
           }
       }
       close REQ;
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


sub print_main_menu {
    @cls_files = CLASS->list();

    CN_UTILS::print_cn_header("Main Menu");

    print <<"START_FORM";
<FORM METHOD=POST 
ACTION="$GLOBALS::SCRIPT_ROOT/get_login">
<INPUT TYPE=hidden NAME=cn_option VALUE="Get Login">
 <TABLE WIDTH=60%> 
<TR ALIGN="CENTER"> <TD ALIGN="LEFT"><B>Login Directions</B><BR>
Step 1. Click on a class name<BR>
Step 2. Click on Login<BR>
<P>
<B>First-time Options</B><BR>
<B>Students:</B> <A 
HREF="$GLOBALS::SECURE_SCRIPT_ROOT/get_stud_reg_form">Join a 
ClassNet class</A><BR>
<B>Instructors:</B> <A 
HREF="$GLOBALS::SECURE_SCRIPT_ROOT/get_class_reg_form">Create a 
ClassNet class</A> </TD>
</TD>
<TD>
<B>Classes</B><BR>
<SELECT SIZE=20  NAME="Class Name">
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
</BODY>
</HTML>
END_FORM
}

sub list {
          
open(CLASS_LIST, "<$GLOBALS::CLASSNET_ROOT_DIR/class_list") or
    &ERROR::system_error("CLASS","list","open",
                         "$GLOBALS::CLASSNET_ROOT_DIR/class_list");
    my @list = <CLASS_LIST>;
    chop @list;
    close CLASS_LIST;
    return @list;
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

package MEMBER;

sub new {
   my($class, $query, $cls, $uname) = @_;
   my $self = {};
   bless $self;
   $self->{'Root Dir'} = $cls->{'Root Dir'};

   # Registration?
   if ($query and defined $query->{'First Name'}->[0]) {
       $self->{'Email Address'} = $query->{'Email Address'}->[0];
       $self->{'Password'} = $query->{'Password'}->[0];
       my $fname = $self->{'First Name'} = CN_UTILS::remove_spaces($query->{'First Name'}->[0]);
       my $lname = $self->{'Last Name'} = CN_UTILS::remove_spaces($query->{'Last Name'}->[0]);
       #if ($fname =~ /\W/) {
       #    ERROR::user_error($ERROR::BADNAME,$fname);
       #}
       # need to allow for hyphens and other weird characters
       #if ($lname =~ /\W/) {
       #    ERROR::user_error($ERROR::BADNAME,$lname);
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
       $self->{'Username'} = ($uname ? $uname : $query->{'Username'}->[0]);
       # Change Username to disk representation;
       my ($last,$first) = split(/, /,$self->{'Username'});
       $self->{'Last Name'} = $last;
       $self->{'First Name'} = $first;
       $self->{'Disk Username'} = CGI::escape($self->{'Username'});
       $self->set_info($cls);
   }

   return $self;
}

sub check_password {
   my ($self, $query) = @_;
   ($self->{'Password'} eq $query->{'Password'}->[0]) or
       &ERROR::user_error($ERROR::PWDBAD);
}

sub set_info {
   my ($self,$cls) = @_;

   # Get the member type
   my $mem_type = $cls->mem_exists($self->{'Disk Username'});
   unless ($mem_type) {
       	   &ERROR::user_error($ERROR::MEMBERNF,$self->{'Username'});
   }

   # Open the file
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$self->{'Disk Username'}";

   $/ = "\n";
   (open(MEM_FILE, "<$fname")) or
       	   &ERROR::system_error("MEMBER","set_info","Open",$self->{'Username'});

   chomp(@mem_list = <MEM_FILE>);
   close(MEM_FILE);
   foreach (@mem_list) {
       my ($mem_name,$mem_value) = split(/=/);
       $self->{$mem_name} = $mem_value;
   }
}

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
<FORM METHOD=POST ACTION="$GLOBALS::SECURE_ROOT$ENV{'SCRIPT_NAME'}">
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

package STUDENT;

@ISA = qw( MEMBER );

sub new {
   my($class, $query, $cls, $uname) = @_;
   my $self = MEMBER->new($query, $cls, $uname);
   $self->{'Member Type'} = 'student';
   bless $self;
}

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
    ASSIGNMENT->print_listbox($cls,'published');
    print <<"FORM";
<BR>
<H4>
<INPUT TYPE=submit  NAME=cn_option VALUE=Complete>
<INPUT TYPE=submit  NAME=cn_option VALUE=Answers>
<INPUT TYPE=submit  NAME=cn_option VALUE=Scores>
FORM
    if (-e "$cls->{'Root Dir'}/scores.gif") {
        print "<INPUT TYPE=submit  NAME=cn_option VALUE=Histogram>";
    }
    print <<"FORM";
<INPUT TYPE=submit  NAME=cn_option VALUE="Personal Data">
FORM
    if ($cls->{'ShowComm'} ne 'no') {
    print <<"FORM";
<P><B>Communication</B><BR>
<INPUT TYPE=submit  NAME=cn_option VALUE=Email>
<INPUT TYPE=submit  NAME=cn_option VALUE=Discuss>
<INPUT TYPE=submit  NAME=cn_option VALUE=Chat>
FORM
    }
    print <<"FORM";
<P>
<INPUT TYPE=submit  NAME=back VALUE="Logout">
</H4>
</CENTER>
$msg
FORM
    print "<CENTER>$GLOBALS::HR</CENTER>\n";
    print "<H3><CENTER>\n";
    print $GLOBALS::RED_BALL;
    print " <A HREF=\"$GLOBALS::HELP_ROOT/student_menu.html\">Help </A>\n";
    print "</CENTER></H3>\n</BODY>\n</HTML>\n";
}

package INSTRUCTOR;

@ISA = qw( MEMBER );

sub new {
   my($class, $query, $cls, $uname) = @_;
   my $self = MEMBER->new($query, $cls, $uname);
   $self->{'Member Type'} = 'instructor';
   bless $self;
}

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

package ASSIGNMENT;

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

1;



