# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

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
        $line =~ s/"//g;
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
        # if ($score > 0) {
            print "<INPUT NAME=\"stu_$sname\" SIZE=3 VALUE=$score>
$sname<BR>\n";
        # } else {
        #    push(@zero,$sname);
        # }
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

1;
