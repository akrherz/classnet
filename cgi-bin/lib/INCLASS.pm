package INCLASS;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader, ASSIGNMENT);
#@ISA = qw( ASSIGNMENT );

#########
=head1 INCLASS

=head1 Methods:

=cut
#########

require ASSIGNMENT;

#########################################
=head2 new($query, $cls, $member, $assign_name)

=over 4

=item Description

=item Params

=item Instance Variables

=item Returns
INCLASS object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $assign_name) = @_;
   my $self = ASSIGNMENT->new($query,$cls,$member,$assign_name);
   bless $self, $class;
   $self->{'Editor Type'} = 'INCLASSEDITOR';
   return $self;
}

# Prevent AutoLoader from looking for DESTROY.al
sub DESTROY { }

__END__

#########################################
=head2 create()

=over 4

=item Description
Create an TEST

=item Params
none

=item Returns
none

=back

=cut

sub create {
    my ($self) = @_;
    ASSIGNMENT->create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('TEST','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type TP=100>";
    close OPTION;
}

sub get_graded_form {
    my $self = shift;
    $self->read_test();
    my $pr = $self->{'PR'};
    my $tp = $self->{'TP'};
    return "<B>Score:</B> $pr of $tp (No answers available for In-class assignments)"; 
}

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $mem = $cls->get_member('',$stud_name);
   my $asn = INCLASS->new('',$cls,$mem,$asn_name);
   $asn->read_test();
   my $tp = $asn->{'TP'};
   my $pr = $asn->{'PR'};
   my $text = "<B>$asn_name:</B> $pr/$tp<BR>";
   return ($text,$tp,$pr);
}

sub send_ungraded_form {
   my $self = shift;
   ERROR::user_error($ERROR::NOTDONE,"complete the <B>$self->{'Name'}</B>
 assignment since only your instructor can set your score");
}

sub send_edit_form {
    my ($self,$query,$stu) = @_;
    my @students = @{$stu};
    my $tkt = $query->param('Ticket');
    TEST->print_test_header("In-class Scores<BR>$self->{'Name'}");
    print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/gradebook">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$tkt">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
FORM
    $cls = $self->{'Class'};
    my %assign_params = $self->read();
    $assign_params{'PR'} = 0;
    print "<B>Total Points:</B> <INPUT NAME=total SIZE=3 VALUE=$assign_params{'TP'}><HR>\n";
    foreach $sname (@students) {
        my $mem = $cls->get_member('',$sname);
        my $asn = INCLASS->new('',$cls,$mem,$self->{'Name'});
        $asn->read_test();
        my $pr = $asn->{'PR'};
        if ($pr == 0) {
          $pr = '0';
        }
        print "<INPUT NAME=\"stu_$sname\" SIZE=3 VALUE=$pr> $sname<BR>\n";
    }
    print "<CENTER><H4><INPUT TYPE=submit Value=Submit> <INPUT TYPE=reset> 
<INPUT TYPE=submit NAME=cancel VALUE=Cancel></H4></CENTER>";
    CN_UTILS::print_cn_footer();
    exit(0);
}

sub read_test {
   my ($self) = @_;
   my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
   if ($self->get_status() eq 'graded') {
       $/ = "\n";
       open(ASSIGN, "<$fname") or
           ERROR::system_error("INCLASS","read_test","open",$fname); 
       flock(ASSIGN, $LOCK_EX);
       $header = <ASSIGN>;
       flock(ASSIGN, $LOCK_UN);
       close(ASSIGN);
       (($header =~ m/\sPTS="([^"]*)/i) or ($header =~m/\sPTS=(\S*)/i)) and
           $tp = $1;
       (($header =~ m/\sPR="([^"]*)/i) or ($header =~m/\sPR=(\S*)/i)) and
           $pr = $1;
   } else {
       my %params = $self->read();
       $tp = $params{'TP'};
       $pr = 0;
   }
   $self->{'TP'} = $tp;
   $self->{'PR'} = $pr;
}

sub submit_edit_changes {
    my ($self,$query) = @_;
    my $cls = $self->{'Class'};
    my $asn = INCLASS->new($query,$cls,'',$self->{'Name'});
    my %params = $asn->read();
    $tp = $query->param('total');
    $params{'TP'} = $tp;
    $self->write(%params);
    # verify that points given is between 0 and total points
    foreach $tname ($query->param()) {
        if ($tname =~ /stu_(.*)/) {
            my $pr = $query->param($tname);
            if ($tp > 0) {
                if  ($pr < 0 or $pr > $tp) {
                     ERROR::user_error($ERROR::NOTDONE,"save points 
because the points received for $1 is not between 0 and $tp");
                }
            } else {
                if  ($pr > 0 or $pr < $tp) {
                     ERROR::user_error($ERROR::NOTDONE,"save points because
the points received for $1 is not between $tp and 0");
                }
            }
        }
    }
    foreach $tname ($query->param()) {
        if ($tname =~ /stu_(.*)/) {
            my $mem = $cls->get_member('',"$1");
            my $asn = INCLASS->new($query,$cls,$mem,$self->{'Name'});
            my $pr = $query->param($tname);
            $asn->{'TP'} = $tp;
            $asn->{'PR'} = $pr;
            $asn->write_test('graded');
        }
    }
}

sub write_test {
   my ($self, $status) = @_;
   if ($status eq 'graded') { 
       $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
   } 
   else {
       $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   }

   # Open file
   open(ASSIGN, ">$fname") or
       ERROR::system_error("INCLASS","write_test","open",$fname); 
   flock(ASSIGN, $LOCK_EX);
   $type = ref($self);
   print ASSIGN "<CN_ASSIGN TYPE=$type SUBMIT=1 PTS=$self->{'TP'} PR=$self->{'PR'} >\n";
   flock(ASSIGN, $LOCK_UN);
   close(ASSIGN);
   chmod 0600, $fname;
   # If we wrote a graded test, make sure the ungraded file is removed
   ($status eq 'graded') and unlink "$self->{'Ungraded Dir'}/$self->{'Student File'}";
}

sub get_new_form {
   my ($self,$memtype,$submit) = @_;
   my %params = $self->read();
   $self->{'TP'} = $params{'TP'};
   $self->{'PR'} = 0;
   $self->write_test('graded');
}

sub get_stats {
    my ($self,$stats,$tot) = @_;
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $pr = $self->{'PR'};
        if (defined $tot->{$pr}) {
            $tot->{$pr}++;
        } else {
            $tot->{$pr} = 1;
        }
    }
}

sub format_stats {
    my ($self,$stats,$tot) = @_;
    my $fname = "$$.dat";
    open(DATA,">$fname");
    my $max = 0;
    foreach $v (keys %{$tot}) {
        my $n = $tot->{$v}; 
        print DATA "$v $n\n";
        ($n > $max) and $max = $n;
    }
    close(DATA);
    my $tp = $self->{'TP'};
    TEST->print_test_header("Statistics");
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
    print <<"HEAD";
<CENTER><H4>$self->{'Name'}</H4>$GLOBALS::HR
<IMG BORDER=2 SRC=$gname>
</CENTER>
HEAD
    CN_UTILS::print_cn_footer();
}

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = "$sname";
    my $name = $self->{'Name'};
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $pr = $self->{'PR'};
        $body .= "\t$pr";
    }
    $body .= "\n";
}

sub upload {
    my ($self,$hfile) = @_;

    $self->create();
    # get all students and put the last, first name in an associative
    # array $srec keyed by the upper case version of last name. If
    # there are duplicate last names, separate records by tabs
    # Then for each record of the form LAST FIRST x x x SCORE
    # where x x x may be other fields which are present but ignored
    # (e.g. SSN), look up by last name. If found, check if records are
    # unique. If so, mark it as found and delete it from $srec
    # if it is not unique, search through the records with the same
    # name to see if first names match. If so, mark it as found.
    # Mark all other cases as missing. It is possible to assign a
    # wrong score if there are students with the same last and first name.

    my $query = $self->{'Query'};
    my $tkt = $query->param('Ticket');
    $cls = $self->{'Class'};
    CN_UTILS::print_cn_header("In-class Scores: $self->{'Name'}");
    print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/assignments">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$tkt">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
FORM
    my %assign_params = $self->read();
    $assign_params{'PR'} = 0;
    print "<B>Total Points:</B> <INPUT NAME=total SIZE=3 VALUE=$assign_params{'TP'}><HR>\n";
    my $cls = $self->{'Class'};
    my @students = $cls->get_mem_names('student');
    my %srec = {};
    my %scores = {};
    foreach $sname (@students) {
        my ($last,$first) = split(/, /,$sname);
        my $ulast = "\U$last";
        $scores{$sname} = 0;
        $srec{$ulast} .= "$sname\t";
    }
    my @lines = split(/\n/,$hfile);
    my @missing = ();
    foreach $line (@lines) {
        my @fields = split(/[\s,]+/,"\U$line");
        my $last = $fields[0];
        my $first = $fields[1];
        my $score = $fields[$#fields];
        if ($srec{$last}) {
           my @fnd = split(/\t/,$srec{$last});
           if ($#fnd == 0) {
               $sname = $fnd[0];
               $scores{$sname} = $score;
               delete $srec{$last};
           } else {
               my $tstr = '';
               foreach $s (@fnd) {
                   if ($s =~ /$last, $first/i) {
                       $sname = $s;
	               $scores{$sname} = $score;
                   } else {
                       $tstr .= "$s\t";
                   }
               }
               if ($tstr eq '') {
                   delete $srec{$last};
               } else {
                   $srec{$last} = $tstr;
               }
           }
        } else {
           push(@missing,$line);
        }
    }
    my @zero = ();
    foreach $sname (sort keys %scores) {
        my $score = $scores{$sname};
        if ($score > 0) {
            print "<INPUT NAME=\"stu_$sname\" SIZE=3 VALUE=$score>
$sname<BR>\n";
        } else {
            push(@zero,$sname);
        }
    }
    print "<P>The following students did not have a score:<P>";
    my $zname = '';
    foreach $sname (@zero) {
        $zname .= "$sname\n";
        print "<INPUT NAME=\"stu_$sname\" SIZE=3 VALUE=0>
$sname<BR>\n";
    }
    print "<P>The following student records could not be found. Please enter
manually:<P>";
    print "<TEXTAREA NAME=Missing ROWS=10 COLS=50 WRAP=PHYSICAL>";
    my $miss = '';
    foreach $line (@missing) {
        $miss .= $line;
    }
    print "$miss</TEXTAREA><P>";
    print "<CENTER><H4><INPUT TYPE=submit Value=Submit> <INPUT TYPE=reset> 
<INPUT TYPE=submit NAME=cancel VALUE=Cancel></H4></CENTER>";
    CN_UTILS::print_cn_footer();
    return "***Missing records***\n$zname\n***Unresolved records***\n$miss"; }

sub grade {

   my $self = shift;

   my $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}"; 
   if (-e $fname) {
       rename($fname,"$self->{'Graded Dir'}/$self->{'Student File'}");
   }
}

sub ungrade {
    # no need to ungrade an INCLASS assignment
}
1;



