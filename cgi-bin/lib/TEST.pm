package TEST;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader, ASSIGNMENT);
#@ISA = qw( ASSIGNMENT );

#########
=head1 TEST

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
TEST object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $assign_name) = @_;
   my $self = ASSIGNMENT->new($query,$cls,$member,$assign_name);
   bless $self, $class;

   $self->{'Key Path'} = "$cls->{'Root Dir'}/assignments/$self->{'Disk Name'}/key";
   $self->{'Editor Type'} = 'TESTEDITOR';
   return $self;
}

__END__

#########################################
=head2 create()

=over 4

=item Description
Create a TEST

=item Params
none

=item Returns
none

=back

=cut

sub create {
    my ($self) = @_;
    ASSIGNMENT::create($self);
    my $dir = $self->{'Dev Root'};
    open(OPTION,">$dir/options") or
        ERROR::system_error('TEST','create',"open","$dir/options");
    $type = ref($self);
    print OPTION "<CN_ASSIGN TYPE=$type>";
    close OPTION;
    $self->insert_block(1);
}

#########################################
=head2 replace_placeholders($val, $block_num,$question_num,%q_params)

=over 4

=item Description
Replaces <?> in HTML code

=item Params
$val: Set equal to "" if no value replacement is to take place.
Hopefully this will not interfere with "" answers?

$block_num: Block number

$question_num: Question Number

%q_params: Question parameters

=item Returns
converted HTML string

=back

=cut

sub replace_placeholders {
   my ($self, $val, $block_num, $question_num, %q_params) = @_;
   my $name = "$block_num.$question_num";
   my $q_str = $q_params{'qtext'};

   $_ = $q_params{'Question Type'};
   SWITCH: {
       /CHOICE|LIKERT/  &&
       	   do {
       	       my $j=0;
       	       $q_str =~ s/<\?>/eval 
                   { $j++; my $check = ($j == $val) ? "CHECKED" : "";
       	       	     "<INPUT TYPE=radio NAME=\"$name\" VALUE=$j $check> " 
                   }/eg;
       	       last SWITCH;
       	      };

       /MULTIPLE/  &&
       	   do {
       	       my $j=0;
               my @picks = split(/%2C/,$val);
       	       $q_str =~ s#<\?>#eval 
                   { $j++; $check = '';
                     foreach $num (@picks) {
                         if ($num == $j) {
                             $check = 'CHECKED';
                             last;
                         }
                     }
       	       	     "<INPUT TYPE=checkbox NAME=$name.$j VALUE=1 $check> " 
                   }#eg;
       	       last SWITCH;
       	      };

       /BLANK/ &&
       	   do {
       	       my $j=0;
       	       # Can't use $val alone because it could be zero;
       	       if ($val ne '') {
       	       	   # split on any escaped commas
       	       	   my @ans_array = split(/%2C/,$val);
                   my @blanks = split(/<\/\?>/,$q_str);
                   my $j = 0;
                   $q_str = '';
                   foreach $blank (@blanks) {
                       $j++;
                       if ($blank =~ /((.|\n)*)<\?>(.*)/) {
                           $n=length($3);
                           $q_str .= "$1 <INPUT NAME=$name.$j SIZE=$n VALUE=\"$ans_array[$j-1]\"> "
                       } else {
                           $q_str .= $blank;
                       }
                   }
       	       }
       	       else {
                   my @blanks = split(/<\/\?>/,$q_str);
                   my $j = 0;
                   $q_str = '';
                   foreach $blank (@blanks) {
                       $j++;
                       if ($blank =~ /((.|\n)*)<\?>(.*)/) {
                           $n=length($3);
                           $value = $n > 0 ? "VALUE=\"$3\"" : "";
                           $q_str .= "$1 <INPUT NAME=$name.$j $value SIZE=$n> ";
                       } else {
                           $q_str .= $blank;
                       }
                   }
       	       }
       	       last SWITCH;
       	      };

       /ESSAY/ &&
       	   do {
       	       my ($rows, $cols);
               $q_params{'ROWS'} and $rows = "ROWS=$q_params{'ROWS'}";
               $q_params{'COLS'} and $cols = "COLS=$q_params{'COLS'}";
       	       if ($val eq "") {
       	       	   if ($q_str =~ m/<\?>(.*)<\/\?>/si) {
       	       	       $val = $1;
       	       	       !($val =~ /\S/) and
       	       	       	   $val="";
       	       	   }
       	       }
       	       $q_str =~ s/<\?>.*<\/\?>/<TEXTAREA NAME=\"$name\" $rows
$cols WRAP=physical>$val<\/TEXTAREA> /si;
       	       last SWITCH;
       	      };
       /OPTION/ &&
       	   do {
               ($q_str,$rest) = split(/<\/\?>/,$q_str);
	       # I am not sure why we have to reverse it here, just append </SELECT> below 
       	       #$q_str = reverse $q_str;
       	       #$q_str =~ s/([\n?.*>\?]{1}?)/>TCELES<\n$1/;
       	       #$q_str = reverse $q_str;
       	       $q_str =~ s/(<\?>)/<SELECT NAME=\"$name\"> \n$1/;
       	       $q_str =~ s/<\?>/<OPTION> /g;
      	       # Can't use $val alone because it could be zero;
               ($val ne "") and
       	       	   $q_str =~ s/<OPTION>([\s|\n]*$val[\s|<|\n])/<OPTION SELECTED> $1/s;
               $q_str .= "</SELECT>\n$rest";
       	       last SWITCH;
       	      };
       /LIST/ &&
       	   do {
       	       my $size;
               ($q_str,$rest) = split(/<\/\?>/,$q_str);
               $q_params{'ROWS'} and $size = "SIZE=$q_params{'ROWS'}";
       	       #$q_str = reverse $q_str;
       	       #$q_str =~ s/([\n?.*>\?]{1}?)/>TCELES<\n$1/;
       	       #$q_str = reverse $q_str;
       	       $q_str =~ s/(<\?>)/<SELECT NAME=\"$name\" $size> \n$1/;
       	       $q_str =~ s/<\?>/<OPTION> /g;
      	       # Can't use $val alone because it could be zero;
               ($val ne "") and
       	       	   $q_str =~ s/<OPTION>([\s|\n]*$val[\s|<|\n])/<OPTION SELECTED> $1 /s;
               $q_str .= "</SELECT>\n$rest";
       	       last SWITCH;
       	      };
       }
       return $q_str;
}

#########################################
=head2 block_count()

=over 4

=item Description
Return number of blocks in test

=item Params
none

=item Returns
number of blocks

=back

=cut

sub block_count {
    my ($self) = @_;
    opendir(BLOCKS,$self->{'Dev Root'});
    my $n = grep(/^\d+$/,readdir(BLOCKS));
    close BLOCKS;
    return $n;
}

#########################################
=head2 get_blocks()

=over 4

=item Description
Get list of blocks

=item Params
none

=item Returns
List of numerically sorted block numbers

=back

=cut

sub get_blocks {
    my ($self) = @_;
    opendir(BLOCKS,$self->{'Dev Root'}) or
       	   &ERROR::system_error('TEST','get_blocks','opendir',"$self->{'Dev Root'}");
    my @blocks = grep(/^\d+$/,readdir(BLOCKS));
    close BLOCKS;
    sort {$a <=> $b} @blocks;
}

#########################################
=head2 question_count($b)

=over 4

=item Description
Returns number of questions in block $b

=item Params
$b: block number

=item Returns
number of questions in block $b


=back

=cut

sub question_count {
    my ($self,$b) = @_;
    opendir(QUEST,"$self->{'Dev Root'}/$b") or
       	ERROR::system_error('TEST','question_count','opendir',"$self->{'Dev Root'}/$b");
    my $q = grep(/^\d+$/,readdir(QUEST));
    close QUEST;
    return $q;
}

#########################################
=head2 delete_block($b)

=over 4

=item Description
renames block $b to .clipb and renumbers
remaining blocks
 
=item Params
$b: block number

=item Returns
none

=back

=cut

sub delete_block {
    my ($self,$b) = @_;
    my $nb = $self->block_count();
    my $cls = $self->{'Class'};
    my $clip = "$cls->{'Root Dir'}/assignments/.develop/.clipb";
    my $dir = $self->{'Dev Root'};
    system "rm -r $clip";
    rename("$dir/$b","$clip") or
        ERROR::system_error('TEST','delete_block','rename',"$dir/$b to $dir/.clipb");
    for ($old = $b + 1; $old <= $nb; $old++) {
        $new = $old - 1;
        rename("$dir/$old","$dir/$new") or
            ERROR::system_error('TEST','delete_block','rename',"$dir/$old to $dir/$new");
    }
}

#########################################
=head2 delete_question($b,$q)

=over 4

=item Description
Renames question $q in block $b to .clipq and
renumbers remaining questions

=item Params
$b: block number
$q: question number

=item Returns
none

=back

=cut

sub delete_question {
    my ($self,$b,$q) = @_;
    $nq = $self->question_count($b);
    if ($nq == 1) {
        ERROR::system_error('TEST','delete_question','delete last question',"$dir/$b/1");
    }
    my $cls = $self->{'Class'};
    my $clip = "$cls->{'Root Dir'}/assignments/.develop/.clipq";
    $dir = $self->{'Dev Root'};
    rename ("$dir/$b/$q",$clip) or
        ERROR::system_error('TEST','delete_question','rename',"$dir/$b/$q");
    for ($old = $q + 1; $old <= $nq; $old++) {
        $new = $old - 1;
        rename("$dir/$b/$old","$dir/$b/$new") or
            ERROR::system_error('TEST','delete_question','rename',"$dir/$b/$old");
    }
}

#########################################
=head2 insert_block($b)

=over 4

=item Description
Inserts a new block at position $b

=item Params
$b: block number

=item Returns
none

=back

=cut

sub insert_block {
    my ($self,$b) = @_;
    $dir = $self->{'Dev Root'};
    $nb = $self->block_count();
    if ($b < 1 || $b > ($nb + 1)) {
        return;
    }
    # rename remaining blocks upward and then insert
    for ($old = $nb; $old >= $b; $old--) {
        $new = $old + 1;
        rename("$dir/$old","$dir/$new");
    }
    mkdir("$dir/$b",0700) or
        ERROR::system_error('TEST','insert_block','mkdir',"$dir/$b");
    open(OPTION,">$dir/$b/options") or
        ERROR::system_error('TEST','insert_block','open',"$dir/$b/options");
    print OPTION "<CN_BLOCK NAME=\"new block\">\n";
    close OPTION;
    $self->insert_question($b,1);
}

#########################################
=head2 insert_question($b,$q)

=over 4

=item Description
Inserts a new question in block $b
at position $q

=item Params
$b: block number
$q: question number

=item Returns
none

=back

=cut

sub insert_question {
    my ($self,$b,$q) = @_;
    $dir = $self->{'Dev Root'};
    $nq = $self->question_count($b);
    if ($q < 1 || $q > ($nq + 1)) {
        return;
    }
    for ($old = $nq; $old >= $q; $old--) {
        $new = $old + 1;
        rename("$dir/$b/$old","$dir/$b/$new");
    }
    open(QUEST,">$dir/$b/$q") or
        ERROR::system_error('TEST','insert_question','open',"$dir/$b/$q");
    print QUEST "<CN_Q>\n";
    close QUEST;
}

#########################################
=head2 grade()

=over 4

=item Description
Grade this test

=item Params
none

=item Returns
none

=back

=cut

sub grade {
   my ($self) = @_;

   # no need to grade if not published
   if ($self->{'Dev Root'} =~ /.develop/) {
       return;
   }

   # Do we have the key header?
   if (!$self->{'Key Header'})  {
       my %assign_params = $self->read();
       (%assign_params) or
            ERROR::system_error('TEST','grade','read header',
                                "$self->{'Dev Root'}/options");
       $self->{'Key Header'} = \%assign_params;
   }

   # Only grade if after the due date
   (!$self->due_date_past() and (defined $self->{'Key Header'}{'DUE'}))  and 
       return;

   # Has key been read or constructed?
   $self->{'Key'} or $self->read_key();

   # Read the ungraded assignment
   if ($self->read_test() == 0) {
       return;
   }

   # Has at least one submission occurred?
   if ($self->{'Test Header'}{'SUBMIT'} == 0) {
       return;
   }

   # Perform the grading
   my @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   my $key = $self->{'Key'};
   my $stud_ans = $self->{'Stud Answers'};
   my $pts_rec = 0;
   my $q_status = "graded";
   while (@q_names) {
       my $q_name = shift(@q_names);
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my @q_list = ();
       if (defined $blank_num) {
           $root = "$b_num.$q_num";
           $n = $key->{$root}{'N'};
           $ans = $key->{$root}{'ANS'};
           if ($key->{$root}{'Question Type'} =~ /BLANK/i) {
               $correct = 1;
       	       # answers were already split in read_key
               # @answers = split(/%2C/,$ans);
               for ($i = 1; $i <= $n; $i++) {
                   if ($correct and !$self->match($key->{"$root.$i"}{'ANS'},
                                    $stud_ans->{"$root.$i"}{'ANS'},
                                    $key->{$root}{'JUDGE'})) {
                       $correct = 0;
                   }
                   #NOTE: This list sequence will likely not match for loop sequence
                   push(@q_list,$q_name);
                   $q_name = shift(@q_names);
               }

               (defined $q_name) and unshift(@q_names,$q_name);
               $q_name = "$root.1";
           } elsif ($key->{$q_name}{'Question Type'} =~ /MULTIPLE/i) {
               $correct = 1;
               my %values = $self->get_runtime_values();
               (%values) and $ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
               $ans =~ s/{\s*(\w+)\s*}//g;
               $ans = CN_UTILS::remove_spaces($ans);
               @answers = split(/,/,$ans);
               for ($i = 1; $i <= $n; $i++) {
                   my $is_ans = 0;
                   if ($ans ne '') {
                       foreach $a (@answers) {
                           if ($a == $i) {
                               $is_ans = 1; last;
                           }
                       }
                       if (($is_ans and !$stud_ans->{"$root.$i"}{'ANS'}) or
                           (!$is_ans and $stud_ans->{"$root.$i"}{'ANS'})){
                           $correct = 0;
                       }
                   }
                   push(@q_list,$q_name);
                   $q_name = shift(@q_names);
               }
               (defined $q_name) and unshift(@q_names,$q_name);
               $q_name = "$root.1";
          };
       } else {
           if (!($key->{$q_name}{'Question Type'} =~ /LIKERT/i)) {
               $correct = $self->match($key->{$q_name}{'ANS'}, 
                                       $stud_ans->{$q_name}{'ANS'},
                                       $key->{$q_name}{'JUDGE'});
           }
           push(@q_list,$q_name);
       }
       if ($key->{$q_name}{'Question Type'} =~ /ESSAY/i) {
           $q_status = "partial";
           $pts = $stud_ans->{$q_name}{'PR'};
           push(@q_list,$q_name);
       } elsif ($key->{$q_name}{'Question Type'} =~ /LIKERT/i) {
           $ans = $key->{$q_name}{'ANS'};
           my %values = $self->get_runtime_values();
           (%values) and $ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
           $ans =~ s/{\s*(\w+)\s*}//g;
           $sans = $stud_ans->{$q_name}{'ANS'};
           if ($ans eq '') {
               $pts = $sans;
           } else {
               my @wts = split(/,/,$ans);
               $pts = ($sans <= $#wts) ? $wts[$sans-1]:$wts[$#wts];
           }
           push(@q_list,$q_name);
       } else {
           $pts = $correct? $key->{$q_name}{'TP'}: 
                            $key->{$q_name}{'PP'};
       }
       $pts_rec += $pts;
       foreach $qn (@q_list) {
           $stud_ans->{$qn}{'TP'} = $key->{$qn}{'TP'};
           $stud_ans->{$qn}{'PP'} = $key->{$qn}{'PP'};
           $stud_ans->{$qn}{'PR'} = $pts;
       }
   }
   # Set points received and store the graded assignment

   $self->{'Test Header'}{'PR'} = $pts_rec;
   $self->{'Test Header'}{'TP'} = $self->{'Key Header'}{'TP'};
   $self->write_test($q_status);
}

sub match {
    my ($self,$key_ans,$stud_ans,$judge_str) = @_;

    # Need a default?
    $judge_str or $judge_str = 'EXACT';
    my $num = ($judge_str =~ /NUM/);
    my $exact = (($judge_str =~ /EXACT/) and !($judge_str =~ /NOEXACT/));
    my $spell = (($judge_str =~ /SPELL/) and !($judge_str =~ /NOSPELL/));
    my $punc = (($judge_str =~ /PUNC/) and !($judge_str =~ /NOPUNC/));
    my $ord = (($judge_str =~ /ORD/) and !($judge_str =~ /NOORD/));
    my $cnt = (($judge_str =~ /CNT/) and !($judge_str =~ /NOCNT/));
    my $caps = (($judge_str =~ /CAPS/) and !($judge_str =~ /NOCAPS/));

###########################################################
####PATCH: Change when all judge options programmed########
####Only exact and numeric judging#########################
###########################################################  
    # substitute {name} in answer with run-time values
    my %values = $self->get_runtime_values();
    (%values) and $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/g;
    # replace any remaining dynamic values with blank.
    $key_ans =~ s/{\s*(\w+)\s*}//g;
    $key_ans = CN_UTILS::remove_spaces($key_ans);
    # if key_ans is blank then assume student answer is correct
    ($key_ans eq '') and return 1;
    # change escaped | with ascii value
    $key_ans =~ s/\\\|/\%7C/g;

    foreach $ans (split(/\|/,$key_ans)) {
        # restore |
        $ans =~ s/\%7C/\|/g;
        if ($num) {
           # Remove any commas
           $ans =~ s/,//g;
           $stud_ans =~ s/,//g;
           if ($ans =~ m/"?([+|-]?\d+\.?\d*):([+|-]?\d+\.?\d*)/ ) {
       	       my $low = $1 - 0.000001;
       	       my $high = $2 + 0.000001;
       	       (($stud_ans >= $low) and ($stud_ans <= $high)) and return 1;
           }
           else { 
       	       ($ans =~ m/"?([+|-]?\d+\.?\d*)/);
       	       my $diff = abs ($stud_ans - $1);
       	       ($diff <= .000001) and return 1;
           }
        } else {
           if ($caps != 1) {
               $ans = "\U$ans\E";
               $stud_ans = "\U$stud_ans\E";
           }
           if ($punc != 1) {
               $ans =~ s/[!-\/:-@\[-`\{-~]/ /g;
               $stud_ans =~ s/[!-\/:-@\[-`\{-~]/ /g;
           }
           if ($exact != 1) {
              # remove multiple spaces
              $ans =~ s/\s{2}/ /g;
              # remove leading and trailing spaces
              $ans =~ s/^\s+|\s+$//g;
              # remove multiple spaces
              $stud_ans =~ s/\s{2}/ /g;
              # remove leading and trailing spaces
              $stud_ans =~ s/^\s+|\s+$//g;
           }
           ($ans eq $stud_ans) and return 1;
        }
    }
    return 0;
    #return JUDGE::judge($key_ans,$stud_ans,$spell,$punc,$ord,$cnt);
}

#########################################
=head2 write_block($b,%params)

=over 4

=item Description
Save block data to file

=item Params
$b: block number

%params: block parameters

=item Returns
none

=back

=cut

sub write_block {
    my ($self,$b,%params) = @_;
    $hdr = TEST::pack_block_header(%params);
    $fname = "$self->{'Dev Root'}/$b/options";
    open(BLK,">$fname") or
        ERROR::system_error('TEST','write_block','open',$fname);
    print BLK "$hdr\n";
    print BLK $params{'btext'};
    close(BLK);
}

#########################################
=head2 write_question($b,$q,%params)

=over 4

=item Description
Save question to a file

=item Params
%params: block parameters

$b: block number

$q: question number

=item Returns
none

=back

=cut

sub write_question {
    my ($self,$b,$q,%params) = @_;
    my $hdr = TEST::pack_question_header(%params);
    my $qtext = $params{'qtext'};
    my $feedback = $params{'feedback'};
    my $txt = $feedback? join("\n<CN_FEEDBACK>\n",$qtext,$feedback):$qtext;
    my $fname = "$self->{'Dev Root'}/$b/$q";
    open(QUEST,">$fname") or
        &system_error('TEST','write_question','open',$fname);
    print QUEST "$hdr\n";
    print QUEST $txt;
    close(QUEST);
}

#########################################
=head2 read_block($b,$no_unpack)

=over 4

=item Description
Read block data from file

=item Params
$b: block number

$no_unpack: Optional param which if set 
to true does not unpack the header

=item Returns
%params: associative list of TEST values

=back

=cut

sub read_block {
    my ($self,$b,$no_unpack) = @_;
    my (%params, @bdata);

    # Set input record separator and read the file
    $/ = "\n";

    $fname = "$self->{'Dev Root'}/$b/options";
    open(BLK,"<$fname") or
        ERROR::system_error('TEST','read_block','open',$fname);
    @bdata = <BLK>;
    close(BLK);
    if ($no_unpack) {
       $params{'cn_block'} = shift @bdata;
    }
    else {
       my $header = shift @bdata;
       %params = TEST::unpack_block_header($header);
       (%params) or
           ERROR::system_error('TEST','read_block','unpack_block_header',
                               "$fname:$header");
    }

    # Save single string in btext
    $params{'btext'} = join('',@bdata);
    return %params;
}

#########################################
=head2 read_question($b,$q, $no_unpack)

=over 4

=item Description
Read question from file

=item Params
$b: block number

$q: question number

$no_unpack: Optional param which if set 
to true does not unpack the header

=item Returns
%params: associative list of TEST values

=back

=cut

sub read_question {
    my ($self,$b,$q,$no_unpack) = @_;
    my (%params, @qdata);
    my $fname = "$self->{'Dev Root'}/$b/$q";

    # Set input record separator and read the file
    $/ = "\n";
    open(QUEST,"<$fname") or
        ERROR::system_error('TEST','read_question','open',$fname);
    @qdata = <QUEST>;
    close(QUEST);
    if ($no_unpack) { 
       $params{'cn_q'} = shift @qdata;
    }
    else {
       my $header = shift @qdata;
       %params = TEST::unpack_question_header($header);
       (%params) or
           ERROR::system_error('TEST','read_question','unpack_question_header',
                               "$fname:$header");
    }

    # Pull out html and any feedback
    $qdata = join('',@qdata);
    my ($html, $feedback) = split(/<CN_FEEDBACK>\n?/i,$qdata);
    $params{'qtext'} = $html;
    $feedback and $params{'feedback'} = $feedback; 
    return %params;
}

#########################################
=head2 make_key()

=over 4
d
=item Description
Make the key file for this test

=item Params
none

=back

=cut

sub make_key {
   my ($self) = @_;
   my (%params,$b,$nb);
   my $tot_pts = 0;

   # Remove all trailing newlines on chomp
   $/="";

   if (-e $self->{'Key Path'}) {
       return;
   }
   open(KEY,">$self->{'Key Path'}") or
        &ERROR::system_error('TEST','make_key','open',"$self->{'Key Path'}");
   flock(KEY, LOCK_EX);
   $nb = $self->block_count();
   for ($b = 1; $b <= $nb; $b++) {
       # Read in block header <CN_BLOCK...>
       %params = $self->read_block($b,1);
       chomp ($params{'cn_block'});
       # Add to total pts
       if ($params{'cn_block'} =~ m/\sPTS="?([+|-]?[.|\d]+)\/([+|-]*[.|\d]+)/ ) {
       	   $tot_pts += $2;
       }
       elsif ($params{'cn_block'} =~ m/\sPTS="?([+|-]?[.|\d]+)/)  {
       	   $tot_pts += $1;
       }
       else {
       	   $tot_pts += 1;
       }

       $params{'cn_block'} =~ m/<CN_BLOCK.*TP="?(\d+)/i;
       print KEY "$params{'cn_block'}\n";
       $nq = $self->question_count($b);
       for ($q = 1; $q <= $nq; $q++) {
       	   # Read in question header <CN_Q ...>
       	   %params = $self->read_question($b,$q,1);
       	   chomp ($params{'cn_q'});
       	   print KEY "$params{'cn_q'}\n";
       	   if ($params{'feedback'}) {
       	       chomp ($params{'feedback'});
       	       print KEY "$params{'feedback'}\n";
       	   }
       }
       print KEY "</CN_BLOCK>\n";
   }
   flock(KEY, $LOCK_UN);
   close KEY;
   chmod 0600, "$self->{'Key Path'}";

   # Add Total pts to options file
   my %params = $self->read();
   (%params) or
        ERROR::system_error('TEST','make_key','read header',
                            "$self->{'Dev Root'}/options");
   $params{'TP'} = $tot_pts;
   $self->write(%params);

}

#########################################
=head2 delete_key()

=over 4

=item Description
Delete the key file (if any)

=item Params
none

=back

=cut

sub delete_key {
    my ($self) = @_;
    if (-e $self->{'Key Path'}) {
        unlink $self->{'Key Path'};
    }
}

#########################################
=head2 pack_block_header(%params)

=over 4

=item Description
Pack a block header

=item Params
%params: associative array of block values

=item Returns
One line header string "<CN_BLOCK ...>"

=back

=cut

sub pack_block_header {
    my (%params) = @_;
    my $hdr = '<CN_BLOCK PTS=';
    ($params{'PP'} > 0) and $hdr .= "$params{'PP'}/";
    $hdr .= $params{'TP'};
    ($params{'Name'}) and $hdr .= " NAME=\"$params{'Name'}\"";
    return $hdr . '>';
}

#########################################
=head2 unpack_block_header()

=over 4

=item Description
Unpack a header block:

=item Params
$header: The one line header string "<CN_BLOCK ...>"

=item Returns
Associative array of Point values: $grade_info{'TP'} and
$grade_info{'PP'}

=back

=cut

sub unpack_block_header {
   my ($header) = @_;
   my %grade_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_BLOCK\s*/i) or return undef;

   # Get rid of end of line and >
   chomp $header;
   chop $header;

   # Set any defaults
   $grade_info{'TP'} = 1;
   $grade_info{'PP'} = 0;

   # Get block name if any
   (($header =~ m/\sNAME="([^"]*)/i) or ($header =~ m/\sTYPE=(\S*)/i)) and
       $grade_info{'Name'} = $1;

   # Parse out the total and/or partial pts
   if ($header =~ m/\sPTS="?([+|-]?[.|\d]+)\/([+|-]*[.|\d]+)/ ) {
       $grade_info{'TP'} = $2;
       $grade_info{'PP'} = $1;
   }
   elsif ($header =~ m/\sPTS="?([+|-]?[.|\d]+)/)  {
       $grade_info{'TP'} = $1;
       $grade_info{'PP'} = 0;
   }

   # Get rid of any commas
   $grade_info{'TP'} =~ s/,//g;
   $grade_info{'PP'} =~ s/,//g;

   return %grade_info;
}

#########################################
=head2 unpack_stud_question_header()

=over 4

=item Description
Unpack question header in student answer file

=item Params
$header: The one line header string "<CN_Q NAME=.. PTS=..>"

=item Returns
Associative array of Question values

=back

=cut

sub unpack_stud_question_header {
   my ($header) = @_;
   my %q_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_Q\s*/i) or return undef;

   # Get rid of end of line and >
   chomp $header;
   chop $header;

   # Get the stored name
   if (($header =~ m/NAME="([^"]*)/i) or ($header =~ m/NAME=(\S*)/i)) {
       $q_info{'NAME'} = $1;
   }
   else {
       return undef;
   }

   # Any Pts received?
   if ($header =~ m/PR="?([+|-]?[.|\d]+)/ ) {
       $q_info{'PR'} = $1;
   }
   else {
       $q_info{'PR'} = 0;
   }

   # Parse out partial_pts/total_pts
   if ($header =~ m/PTS="?([+|-]?[.|\d]+)\/([+|-]?[.|\d]+)/ ) {
       $q_info{'TP'} = $2;
       $q_info{'PP'} = $1;
   }
   else {
       return undef;
   }
   return %q_info;
}

#########################################
=head2 unpack_stud_test_header($header)

=over 4

=item Description
Unpack test header in student answer file

=item Params
$header: The one line header string "<CN_ASSIGN PTS=..>"

=item Returns
Associative array of Question values

=back

=cut

sub unpack_stud_test_header {
   my ($header) = @_;
   my %t_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_ASSIGN\s*/i) or return undef;

   # Get rid of end of line and >
   chomp $header;
   chop $header;

   # Parse out pts_received/total_pts
   if ($header =~ m/\sPTS="?\s*(\d+)\s*\/\s*(\d+)/i)  {
       $t_info{'TP'} = $2;
       $t_info{'PR'} = $1;
   }
   else {
       return undef;
   }

   # Get submit
   ($header =~ m/SUBMIT="?(\d)/i) and
       $t_info{'SUBMIT'} = $1;

   # Get seen
   ($header =~ m/SEEN="([^"]*)/i) and
       $t_info{'SEEN'} = $1;

   # Get submit date
   ($header =~ m/SUBDATE="([^"]*)/i) and
       $t_info{'SUBDATE'} = $1;

   return %t_info;
}

#########################################
=head2 pack_assign_header(%params)

=over 4

=item Description
Pack a test header

=item Params
%params: associative array of test values

=item Returns
One line header string "<CN_ASSIGN ...>"

=back

=cut

sub pack_assign_header {
    my ($class,%params) = @_;
    $hdr = ASSIGNMENT->pack_assign_header(%params);
    ($hdr =~ /(.+) >/) and $hdr = $1;
    $hdr .= ($params{'FILL'})? ",FILL":",NOFILL"; 
    $hdr .= ($params{'VERS'} > 0)? ",VERS=$params{'VERS'}":'';
    $hdr .= ($params{'MULT'})? ",MULT":''; 
    return $hdr . ' >';
}

#########################################
=head2 unpack_assign_header($header)

=over 4

=item Description
Unpack an test header

=item Params
$header: The one line header string "<CN_ASSIGN ...>"

=item Returns
One element associative array of option values: $assign_info{'OPT'}

=back

=cut

sub unpack_assign_header {
   my ($class,$header) = @_;
   my %assign_info;

   %assign_info = ASSIGNMENT->unpack_assign_header($header);
   (%assign_info) or return undef;

   # Add any defaults
   $assign_info{'VERS'} = ($assign_info{'OPT'} =~ /VERS=(\d+)/) ? $1 : 0;
   $assign_info{'FILL'} = ($assign_info{'OPT'} =~ /NOFILL/) ?  0 : 1;
   $assign_info{'MULT'} = ($assign_info{'OPT'} =~ /MULT/) ?  1 : 0;

   return %assign_info;
}

#########################################
=head2 pack_question_header(%params)

=over 4

=item Description
Pack a question header

=item Params
%params: associative array of question values

=item Returns
One line header string "<CN_Q ...>"

=back

=cut

sub pack_question_header {
    my (%params) = @_;
    my $hdr = '<CN_Q ';
    $hdr .= "TYPE=$params{'Question Type'} ";
    ($params{'ANS'}) 
        and $hdr .= "ANS=\"$params{'ANS'}\" ";
    ($params{'JUDGE'}) 
        and $hdr .= "JUDGE=$params{'JUDGE'} ";
    ($params{'ROWS'}) 
        and $hdr .= "ROWS=$params{'ROWS'} ";
    ($params{'COLS'}) 
        and $hdr .= "COLS=$params{'COLS'} ";
    ($params{'N'}) 
        and $hdr .= "N=$params{'N'} ";
    return $hdr . '>';
}

#########################################
=head2 unpack_question_header($header)

=over 4

=item Description
Unpack a question header

=item Params
$header: The one line header string "<CN_Q ...>"

=item Returns
Associative array of question values

=back

=cut

sub unpack_question_header {
   my ($header) = @_;
   my %q_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_Q\s*/i) or return undef;

   # Get rid of any line separators and chop >
   $/="";
   chomp $header;
   chop $header;

   # Put in Question Type default
   $q_info{'Question Type'} = 'CHOICE';

   # Parse out info;
   (($header =~ m/\sTYPE="([^"]*)/i) or ($header =~ m/\sTYPE=(\S*)/i)) and
       $q_info{'Question Type'} = $1;
   (($header =~ m/\sJUDGE="([^"]*)/i) or ($header =~ m/\sJUDGE=(\S*)/i)) and
       $q_info{'JUDGE'} = $1;
   (($header =~ m/\sANS="([^"]*)/i) or ($header =~ m/\sANS=(\S*)/i)) and
       $q_info{'ANS'} = $1;
   ($header =~ m/\sROWS="?\s*(\d+)/i) and
       $q_info{'ROWS'} = $1;
   ($header =~ m/\sCOLS="?\s*(\d+)/i) and
       $q_info{'COLS'} = $1;
   ($q_info{'Question Type'} =~ /BLANK|MULTIPLE/) and
       $q_info{'N'} = (($header =~ m/\sN="?(\d+)/i) ? $1:1);

   # If this is a numeric answer, get rid of any commas in the answer
   # Note: can't do this here because mutliple answers are separated by commas
#   ($q_info{'JUDGE'} =~ /NUM/i) and $q_info{'ANS'} =~ s/,//g;

   # CHECK proper types and add any defaults
   if ($q_info{'Question Type'} =~ /ESSAY/i) {
       $q_info{'ROWS'} or $q_info{'ROWS'} = 1;
       $q_info{'COLS'} or $q_info{'COLS'} = 10;
   }
   elsif ($q_info{'Question Type'} =~ /BLANK/i) {
       $q_info{'COLS'} or $q_info{'COLS'} = 10;
       $q_info{'ROWS'} = 1;
       $q_info{'JUDGE'} or $q_info{'JUDGE'} = 'EXACT';
   }
   elsif ($q_info{'Question Type'} =~ /LIST/i) {
       $q_info{'ROWS'} or $q_info{'ROWS'} = 1;
   }
   elsif (!($q_info{'Question Type'} =~ /CHOICE|OPTION|MULTIPLE|LIKERT/i)) {
       return undef;
   }

   return %q_info;

}

sub submit_edit_changes {
   my ($self,$query) = @_;
   my $pts_rec = 0;
   my $add_sum = 0;

   my $sfile = $query->param('Student File');
   (defined $sfile) and $self->{'Student File'} = $sfile;

   # Read in the student test
   $self->read_test();

   my $stud_ans = $self->{'Stud Answers'};
   my @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});

   # Adjust student answers / grades
   foreach $q_name (@q_names) {
       my $pts = $query->param("$q_name PR");
       if (defined $pts) {
           $add_sum = 1;
       } else {
           $q_name =~ /(\d+)\.(\d+)\.(\d+)/;
           $pts = $query->param("$1.$2 PR");
           $add_sum = ($3 == 1);
       }
       $pts = CN_UTILS::remove_spaces($pts);
       if (!($pts =~ /^\d+$/)) {
           $q_name =~ m/(\d+)\./;
           ERROR::user_error($ERROR::NOTDONE,"store points for question $1 because points received ($pts) is not a whole number");
       }
       #if ($pts < $stud_ans->{$q_name}{'PP'} or
       if ($pts < 0 or
           $pts > $stud_ans->{$q_name}{'TP'}) {
           $q_name =~ m/(\d+)\./;
           ERROR::user_error($ERROR::NOTDONE,"store points for question $1 because points received ($pts) is out of bounds");
       }
       $stud_ans->{$q_name}{'PR'} = $pts;
       if ($add_sum == 1) { $pts_rec += $pts; }
       $stud_ans->{$q_name}{'ANS'} = $query->{$q_name}->[0];
       if (length($query->{$q_name}->[0]) > $GLOBALS::MAX_ANS_LENGTH) {
       	   $q_name =~ m/(\d+)\./;
       	   ERROR::user_error($ERROR::MAXANS, $1);
       }       
   }
   $self->{'Test Header'}{'PR'} = $pts_rec;
   # Write Test back out
   $self->write_test('graded');

}

sub send_edit_form {
   my ($self,$query,$stu) = @_;
   my ($q_name,@q_names,$stud_ans);

   my $nstu = @{$stu};
   if ($nstu != 1) {
      ERROR::print_error_header('Edit?');
      print "Please select only one student.";
      CN_UTILS::print_cn_footer();
      exit(0);
   }
   ($self->get_status() eq 'ungraded') and
       $self->grade();
   my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}"; 
   (-e $fname) or
       ERROR::user_error($ERROR::UNGRADED,
       "$self->{'Member'}->{'Username'} has possibly not turned in
$self->{'Name'} or Classnet is waiting for a due date to pass");

   # Read the test
   $self->read_test();

   # Read all blocks and questions
   !($self->{'bl_q'}) and
       $self->read_all();
   my $bl_q = $self->{'bl_q'};
   
   # Start the form
   $form =<<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/gradebook">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$query->{'Ticket'}->[0]">
<INPUT TYPE=hidden NAME="Student File" VALUE="$self->{'Student File'}">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
FORM
   # Construct the form
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   $stud_ans = $self->{'Stud Answers'};
   my %values = $self->get_runtime_values();
   while (@q_names) {
       my $q_name = shift @q_names;
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my $root = "$b_num.$q_num";
       $form .= $self->check_java("$bl_q->{$b_num}{'btext'}","play");
       my $ans = $stud_ans->{$q_name}{'ANS'};
       my $pts = "<B>Points:</B> <INPUT NAME=\"$b_num.$q_num PR\" SIZE=3 VALUE=\"$stud_ans->{$q_name}{'PR'}\"> of $stud_ans->{$q_name}{'TP'}";
       my $key_ans = $bl_q->{$root}{'ANS'};
       (%values) and $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
       $key_ans =~ s/{\s*(\w+)\s*}/Not Available/g;
       my $q_type = $bl_q->{$root}{'Question Type'};
       if ($q_type eq 'LIKERT') {
           $key_ans = 'N/A';
       } elsif ($q_type eq 'BLANK') {
           my @ans_array = ();
           $ans_array[$blank_num-1] = $ans;
       	   $q_name = shift @q_names; 
       	   while ($q_name =~  m/^$root\.(\d+)/) {
       	       $ans_array[$1-1] = ($q_type eq 'MULTIPLE')?
                           "$1":$stud_ans->{$q_name}{'ANS'};
       	       $q_name = shift @q_names;
       	   }
           $ans = join("%2C",@ans_array);
       	   (defined $q_name) and unshift(@q_names, $q_name);
       } elsif ($q_type eq 'MULTIPLE') {
           $ans = '';
           $i = 0;
       	   while ($q_name =~  m/^$root\.(\d+)/) {
       	       if ($stud_ans->{$q_name}{'ANS'} == 1) {
                   $ans .= ($ans eq '')?$1:"%2C$1";
               }
       	       $q_name = shift @q_names;
               $i++;
       	   }
	   if ($i == 0) {
               ERROR::user_error($ERROR::NOTDONE,"show the assignment since the
instructor has changed the questions");
           }
       	   (defined $q_name) and unshift(@q_names, $q_name);
       } elsif ($q_type =~ /ESSAY/) {
       	   #$key_ans = "";
       }
       $question = $self->replace_placeholders($ans, $b_num, $q_num, %{$bl_q->{$root}});
       $form = "$form<B>$b_num)</B> $question<P><B>Answer:</B> $key_ans<br>$pts</b><br>$feedback<HR>";
   }   

   # Finish the form
   $self->print_base_header();
   print "<B>Student:</B> $self->{'Member'}->{'Username'}<BR><B>Current Score:</B> $self->{'Test Header'}{'PR'} of $self->{'Test Header'}{'TP'}$GLOBALS::HR";
   print "$form<H4><CENTER><INPUT TYPE=submit VALUE=\"Submit Changes\"></CENTER></H4></FORM>";
   CN_UTILS::print_cn_footer();
   exit(0);
}


sub send_ungraded_form {
   my $self = shift;
   my ($form,$status,%params);  

   # Check status of assignment
   $status = $self->get_status();

   # Must be ungraded
   ($status eq 'graded') and
       ERROR::user_error($ERROR::GRADED);
   # Get assignment info and check due date
   %params = $self->read();
   (%params) or
        ERROR::system_error('TEST','send_ungraded_form','read header',
                            "$self->{'Dev Root'}/options");
   $self->{'Key Header'} = \%params;
   $self->due_date_past($params{'DUE'}) and
       ERROR::user_error($ERROR::PASTDUE,$params{'DUE'});
   my $due = (defined $params{'DUE'})? "<CENTER>(Due $params{'DUE'})</CENTER><HR>": '';

   if (!$status) {
       # No submission yet
       my $form = $self->get_new_form('student','nosubmit');
       $self->print_base_header();
       print "$due$GLOBALS::HR$form";
   }
   elsif ($status eq 'ungraded') { 
       # Assignment has been submitted but ungraded
       my $form = $self->get_ungraded_form();
       $self->print_base_header();
       print "$due$GLOBALS::HR$form";
   }
   else {
       ERROR::system_error("TEST.pm","send_ungraded_form","$self->{'Name'}","No form found");
   }

   exit(0);
}

sub get_new_form {
   my ($self,$memtype,$submit) = @_;
   my (@blocks, $form, @questions, $question_num, $question, $vers_num);
   my (@names, %q_params, %b_params, %assign_params, $num_questions);
   my $rand_length = (length($self->{'Member'}->{'Last Name'}))**3;
   my $vers_num = 0;
   my $tot_pts = 0;

   # Make a key if it doesn't exist and this isn't instructor
   $self->make_key() unless ($memtype eq 'instructor');

   # Get assignment options(?) and block numbers
   if (!$self->{'Key Header'})  {
       %assign_params = $self->read();
       (%assign_params) or
            ERROR::system_error('TEST','get_new_form','read header',
                            "$self->{'Dev Root'}/options");
       $self->{'Key Header'} = \%assign_params;
   }

   # Set random seed and version number
   srand (time ^ $$ ^ $rand_length);
   ($assign_params{'OPT'} =~ m/VERS=(\d+)/i) and $vers_num = int(rand($1)) + 1;

   # Start the form
   if (!(defined $inst)) {
   $form =<<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/assignments">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit TEST">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Member'}->{'Ticket'}">
FORM
   }
   else {
       $form = "<FORM>";
   }

   my $num_blocks = $self->block_count();
   my $block;
   for ($block=1; $block<=$num_blocks; $block++) {

       # Read the current block and add any html to the form
       %b_params = $self->read_block($block);
       # $form .= $self->check_java($b_params{'btext'},"record");
       if ($memtype eq 'student') {
           $form .= $self->check_java($b_params{'btext'},"record");
       }
       else {
           $form .= $self->check_java($b_params{'btext'},"demo");
       }
       
       # Get number of questions
       $num_questions = $self->question_count($block);

       # Which question number to use?
       if (!$vers_num) {
       	   $question_num = int(rand($num_questions)) + 1;
       }
       elsif ($vers_num > $num_questions) {
       	   $question_num = $num_questions;
       }
       else {
       	   $question_num = $vers_num;
       }

       %q_params = $self->read_question($block,$question_num);
       $question = $self->replace_placeholders("",$block, $question_num, %q_params);

       # Save the name of the question and set pts;
       $tot_pts += $b_params{'TP'};
       if ($q_params{'Question Type'} =~ /BLANK/i) {
           # Multiple blanks may appear in one question.
       	   my $n = $q_params{'N'};
       	   ($n == 0) and
              ERROR::user_msg("A fill in the blank question has no blank.");
       	   my $tot_pts = $b_params{'TP'};
       	   my $part_pts = $b_params{'PP'};
       	   for ($i=1; $i<=$n; $i++) {
       	       push (@names, "<CN_Q NAME=\"$block.$question_num.$i\" PTS=$part_pts/$tot_pts PR=0>\n\n");
       	   }
       } elsif ($q_params{'Question Type'} =~ /MULTIPLE/i) {
           #Total and Partial pts are divided by number of correct answers
       	   my $n = $q_params{'N'};
       	   ($n == 0) and
       	       ERROR::user_msg("A MULTIPLE question has no choices.");
       	   my $tot_pts = $b_params{'TP'};
       	   my $part_pts = $b_params{'PP'};
           #Note in form that this question is MULTIPLE
           $form = "$form\n<INPUT TYPE=hidden NAME=$block. VALUE=MULTIPLE>\n";
       	   for ($i=1; $i<=$n; $i++) {
       	       push (@names, "<CN_Q NAME=\"$block.$question_num.$i\" PTS=$part_pts/$tot_pts PR=0>\n\n");
           }
       } else {
       	   push (@names, "<CN_Q NAME=\"$block.$question_num\" PTS=$b_params{'PP'}/$b_params{'TP'} PR=0>\n\n");
       }
       $form = "$form<B>$block) </B> $question<HR>";
   }

   # Finish the form

   # If instructor just return the form
   if ($memtype eq 'instructor') {
       $form = "$form</FORM>";
       return $form;
   }

   $form = "$form<CENTER><H4><INPUT TYPE=submit Value=Submit>
       	   <INPUT TYPE=reset></H4><p></CENTER>\n</FORM>";

   # Store the question names
   my $file = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   open(STUD_ANS,">$file") or
       ERROR::system_error('TEST.pm',"get_form_string","open",$file);
   my $type = ref($self);
   my $sval = ($submit eq 'submit')? 1 : 0;
   print STUD_ANS "<CN_ASSIGN TYPE=$type SUBMIT=$sval PTS=\"0/$tot_pts\">\n", @names;
   close STUD_ANS;
   chmod 0600, $file;

   return $form;

}

sub get_ungraded_form {
   my $self = shift;
   my ($q_name,@q_names,$stud_ans);

   # Read the test
   $self->read_test();

   # Construct the form
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   $stud_ans = $self->{'Stud Answers'};
   # Start the form

   $form =<<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/assignments">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit TEST">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Member'}->{'Ticket'}">
FORM

   while (@q_names) {
       my $q_name = shift @q_names;
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my %b_params = $self->read_block($b_num);
       $form .= $self->check_java($b_params{'btext'},"record");
       my %q_params = $self->read_question($b_num,$q_num);
       my $ans = $stud_ans->{$q_name}{'ANS'};
       if ($q_params{'Question Type'} eq 'BLANK') {
       # Check for multiple blanks
           if (defined $blank_num) {
               my $root_name = "$b_num.$q_num";
               my @ans_array = ();
               $ans_array[$blank_num-1] = $ans;
       	       $q_name = shift @q_names;
       	       while ($q_name =~  m/^$root_name.(\d+)/) {
       	           $ans_array[$1-1] = $stud_ans->{$q_name}{'ANS'};
       	           $q_name = shift @q_names;
       	       }
               $ans = join("%2C",@ans_array);
       	       (defined $q_name) and unshift(@q_names, $q_name);
           }
       } elsif ($q_params{'Question Type'} eq 'MULTIPLE') {
           $form = "$form\n<INPUT TYPE=hidden NAME=$b_num. VALUE=MULTIPLE>\n";
           $ans = '';
           my $root_name = "$b_num.$q_num";
      	   while ($q_name =~  m/^$root_name.(\d+)/) {
       	       if ($stud_ans->{$q_name}{'ANS'} eq '1') {
                   $ans .= ($ans eq '')?$1:"%2C$1";
               }
       	       $q_name = shift @q_names;
       	   }
       	   (defined $q_name) and unshift(@q_names, $q_name);
       }
       $question = $self->replace_placeholders($ans, $b_num, $q_num, %q_params);
       $form = "$form<B>$b_num)</B> $question<HR>";

   }   
   # Finish the form
   $form = "$form<CENTER><H4><INPUT TYPE=submit VALUE=Submit>
       	   <INPUT TYPE=reset></H4><p></CENTER>\n</FORM>";

   return $form;

}

sub read_all {
   my $self = shift;
   my ($q_name,@q_names,$stud_ans);
   my %bl_q;
   my ($nb, $nq, $b);

   $nb = $self->block_count();
   for ($b = 1; $b <= $nb; $b++) {
       # Read in block header <CN_BLOCK...>
       %params = $self->read_block($b);
       $bl_q{$b} = {%params};
       $nq = $self->question_count($b);
       for ($q = 1; $q <= $nq; $q++) {
       	   # Read in question header <CN_Q ...>
       	   %params = $self->read_question($b,$q);
       	   $bl_q{"$b.$q"} = {%params};
       }
   }

   $self->{'bl_q'} = \%bl_q;
}

sub get_graded_form {
   my $self = shift;
   my ($q_name,@q_names,$stud_ans);

   # First try to grade if ungraded
   ($self->get_status() eq 'ungraded') and
       $self->grade();
   ($self->get_status() ne 'graded') and
       ERROR::user_error($ERROR::UNGRADED);

   # May the test be viewed?
   %assign_params = $self->read();
   ($assign_params{'VIEW'} == 0) and
       ERROR::user_error($ERROR::ASNNOVIEW, $self->{'Name'});

   # Read the test
   $self->read_test();

   # Read all blocks and questions
   !($self->{'bl_q'}) and
       $self->read_all();
   my $bl_q = $self->{'bl_q'};
   
   # Construct the form
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   $stud_ans = $self->{'Stud Answers'};

   $,="<br>  \n";
   # Start the form
   $form = "<FORM>\n";
   my %values = $self->get_runtime_values();
   my $qcnt = 0;
   while (@q_names) {
       my $q_name = shift @q_names;
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my $root = "$b_num.$q_num";
       $form .= $self->check_java("$bl_q->{$b_num}{'btext'}","play");
       my $ans = $stud_ans->{$q_name}{'ANS'};
       $pr = $stud_ans->{$root}{'PR'};
       $tp = $stud_ans->{$root}{'TP'};
       my $key_ans = $bl_q->{$root}{'ANS'};
       if (%values) {
           $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
       }
       # replace remaining dynamic values with N/A
       $key_ans =~ s/{\s*(\w+)\s*}/Not Available/g;
       my $feedback = $bl_q->{$root}{'feedback'};
       my $q_type = $bl_q->{$root}{'Question Type'};
       # Check for multiple blanks
       if ($q_type eq 'BLANK') {
           my @ans_array = ();
           $ans_array[$blank_num-1] = $ans;
       	   $q_name = shift @q_names;
       	   while ($q_name =~  m/^$root\.(\d+)/) {
       	       $ans_array[$1-1] = ($q_type eq 'MULTIPLE')?
                           "$1":$stud_ans->{$q_name}{'ANS'};
       	       $q_name = shift @q_names;
       	   }
           $ans = join("%2C",@ans_array);
       	   (defined $q_name) and unshift(@q_names, $q_name);
           $pr = $stud_ans->{"$root.1"}{'PR'};
           $tp = $stud_ans->{"$root.1"}{'TP'};
       } elsif ($q_type eq 'MULTIPLE') {
           $ans = '';
           $i = 0;
       	   while ($q_name =~  m/^$root\.(\d+)/) {
       	       if ($stud_ans->{$q_name}{'ANS'} == 1) {
                   $ans .= ($ans eq '')?$1:"%2C$1";
               }
       	       $q_name = shift @q_names;
               $i++;
       	   }
	   if ($i == 0) {
               ERROR::user_error($ERROR::NOTDONE,"show the assignment since the
instructor has changed the questions");
           }
       	   (defined $q_name) and unshift(@q_names, $q_name);
           $pr = $stud_ans->{"$root.1"}{'PR'};
           $tp = $stud_ans->{"$root.1"}{'TP'};
       }
       $question = $self->replace_placeholders($ans, $b_num, $q_num, %{$bl_q->{$root}});
       if ($q_type =~ /CHOICE/) {
       	   $key_ans = "$key_ans";
       } elsif ($q_type =~ /LIKERT/) {
           $key_ans = 'N/A';
       } elsif ($q_type =~ /ESSAY/) {
       	   # There are a bunch of ways to do this. Just use another
       	   # textarea box for now
       	   $key_ans = $self->replace_placeholders($key_ans, $b_num, $q_num, %{$bl_q->{$root}});
       	   $key_ans =~ s/.*(<TEXTAREA.*\/TEXTAREA>).*/<br>$1/si;
       }
       ($feedback) and
       	   $feedback = ($feedback =~ /\S/mi) ? "<br>Feedback:$feedback" : "";
       $qcnt++;
       $form =
"$form$qcnt) $question<br><B>Answer:</B> $key_ans<br><B>Points:</b> $pr of $tp<br>$feedback<HR>";
   }   
   # Finish the form
   $form = "$form</FORM><CENTER><B>Total Score:</B> $self->{'Test Header'}{'PR'} of $self->{'Test Header'}{'TP'}</CENTER><P>";
   return $form;
}

sub write_assign_query {
   my ($self) = @_;
   my (%assign_params, $answer_all);
   my $query = $self->{'Query'};

   # Read the student's assignment template
   $self->read_test();

   # Read the options file
   %assign_params =  $self->read();
   (%assign_params) or
        ERROR::system_error('TEST','write_assign_query','read header',
                            "$self->{'Dev Root'}/options");

   # Do not store if only a single submission is allowed and already submitted

   if (defined $assign_params{'PASSWORD'}) {
       if (!$assign_params{'MULT'} and $self->{'Test Header'}{'SUBMIT'}== 1) {
           ERROR::user_error($ERROR::COMPLETED);
       }
   }

   # Write the Query to the ungraded dir
   $answer_all = $assign_params{'FILL'};
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   foreach $q_name (@q_names) {
       if ( $answer_all and !(defined $query->{$q_name})) {
       	   $q_name =~ m/(\d+)\./;
           # don't report missing answer if MULTIPLE question
           if ($query->param("$1.") eq 'MULTIPLE') {
               $query->{$q_name}->[0] = '0';
           } else {
       	       ERROR::user_error($ERROR::ANSWERNF, $1);
           }
       }
       # Store and remove beginning and ending whitespace
       $self->{'Stud Answers'}{$q_name}{'ANS'} = CN_UTILS::remove_spaces($query->{$q_name}->[0]);
       if (length($query->{$q_name}->[0]) > $GLOBALS::MAX_ANS_LENGTH) {
       	   $q_name =~ m/(\d+)\./;
       	   ERROR::user_error($ERROR::MAXANS, $1);
       }
   }
   $self->write_test('ungraded');
}

sub write_test {
   my ($self, $status) = @_;
   my (%answers, @questions, $cn_q, $num_questions, $assign_str, $fname);

   if ($status eq 'ungraded') { 
       $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
       $dt = CN_UTILS::getTime($fname);
   } 
   else {
       $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
       $dt = $self->{'Test Header'}{'SEEN'};
   }

   # Open file
   open(ASSIGN, ">$fname") or
       &ERROR::system_error("TEST","write_test","open",$fname); 
   flock(ASSIGN, $LOCK_EX);
   $type = ref($self);
   if (!defined $dt) {
       $dt = CN_UTILS::getTime($fname);
   }
   $dt = "SEEN=\"$dt\"";
   my $subdt = $self->{'Test Header'}{'SUBDATE'};
   if (!defined $subdt || $status eq 'ungraded') {
       $subdt = CN_UTILS::currentTime();
   }
   $subdt = "SUBDATE=\"$subdt\"";
   my $ungrade = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   if ($status eq 'partial' && (-e $ungrade)) {
     $submit = 2;
   } else {
     $submit = 1;
   }
   print ASSIGN "<CN_ASSIGN TYPE=$type SUBMIT=$submit $dt $subdt PTS=\"$self->{'Test Header'}{'PR'}/$self->{'Test Header'}{'TP'}\">\n";
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});   

   my $stud_ans = $self->{'Stud Answers'};
   foreach $q_name (@q_names) {
       my $pp = $stud_ans->{$q_name}{'PP'};
       my $tp = $stud_ans->{$q_name}{'TP'};
       my $pr = $stud_ans->{$q_name}{'PR'};
       print ASSIGN "<CN_Q NAME=\"$q_name\" PTS=$pp/$tp PR=$pr>\n$stud_ans->{$q_name}{'ANS'}\n";
   }

   flock(ASSIGN, $LOCK_UN);
   close(ASSIGN);
   chmod 0600, $fname;
   # If we wrote a graded test, make sure the ungraded file is removed
   ($status eq 'graded' || $status eq 'partial') and unlink $ungrade;
}

sub read_key {

   my $self = shift;
   my (@cn_blocks, $key_str,  @questions, %questions, $header, @header_block, %q_info, %b_info);
   my (%grade_info, $cn_block, $cn_q, $block_name, $num_questions, %assign_params);

   # Get the test header

   %assign_params = $self->read();
   (%assign_params) or
        ERROR::system_error('TEST','read_key','read header',
                            "$self->{'Dev Root'}/options");
   $self->{'Key Header'} = \%assign_params;
   
   # Make the key if necessary
   $self->make_key();

   # Read key into single string
   open(KEY, "<$self->{'Key Path'}") or
       &ERROR::system_error('TEST',"read_key","open","$self->{'Key Path'}");
   flock(KEY, $LOCK_EX);
   undef $/;
   $key_str = <KEY>;
   flock(KEY, $LOCK_UN);
   close(KEY);

   # Get rid of any ending newlines
   $/="";
   chomp $key_str;

   # Get question blocks from key
   @cn_blocks = split(/\n<\/CN_BLOCK>\n?/,$key_str);

    # Fill in question names, answers and grading data
   for ($block_num=0; $block_num<@cn_blocks; $block_num++) {
       # Get cn_block string       
       @questions = split(/(<CN_Q.*>)/,$cn_blocks[$block_num]);
       chomp @questions;
       $cn_block = shift @questions;

       # Get Pts out of the block
       %b_info = TEST::unpack_block_header($cn_block);
       (%b_info) or
           ERROR::system_error('TEST','read_key','unpack_block_header',
                               "$fname:$cn_block");
       # Parse the cn_q's
       $num_questions = grep(/<CN_Q/, @questions);
       for ($q_num=1; $q_num<=$num_questions; $q_num++) {
       	   $cn_q = shift @questions;

       	   # Get question parameters
       	   %q_info = TEST::unpack_question_header($cn_q);
           (%q_info) or
               ERROR::system_error('TEST','read_key','unpack_question_header',
                                   "$fname:$cn_q");
       	   $q_info{'TP'} = $b_info{'TP'};
       	   $q_info{'PP'} = $b_info{'PP'};

       	   # Any feedback follows the cn_q
       	   $feedback = "";
       	   (@questions and !($questions[0] =~ /<CN_.*>/)) and 
       	       $q_info{'Feedback'} = shift @questions; 

       	   # Get block name
       	   $block_name = $block_num+1;

           $questions{"$block_name.$q_num"} = { %q_info };

       	   # Store array and check for multiples and blanks
       	   # All Blanks and Multiples are named with 3 sets of digits
           if ($q_info{'Question Type'} =~ m/BLANK/i) {
               my $n = @q_info{'N'};
       	       my @answers = split(/,/, $q_info{'ANS'});
       	       grep {s/%22/"/g; s/%2C/,/g} @answers;
       	       for ($i = 1; $i <= $n; $i++) {
       	       	   $questions{"$block_name.$q_num.$i"} = { %q_info };
       	       	   $questions{"$block_name.$q_num.$i"}{'ANS'} = $answers[$i-1];
       	       }
       	   } elsif ($q_info{'Question Type'} =~ m/MULTIPLE/i) {
               my $n = $q_info{'N'};
       	       my $ans = $q_info{'ANS'};
       	       for($i = 1; $i <= $n; $i++) {
       	       	   $questions{"$block_name.$q_num.$i"} = { %q_info };
       	       	   $questions{"$block_name.$q_num.$i"}{'ANS'} = 
                       (($ans =~ /$i/)?$i:0); 
       	       }
       	   }
       }
   }
   # Store reference to %questions
   $self->{'Key'} = \%questions;

}

sub read_test {
   my ($self) = @_;
   my (%answers, @questions, $cn_q, $num_questions, $assign_str, $fname);
   my ($name, %q_info);

   $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
   if (!(-e $fname)) {
       $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   }
   if (!(-e $fname)) {
       return 0;
   }
   # Get questions
   open(ASSIGN, "<$fname") or
       ERROR::system_error("TEST","read_test","open","$fname"); 
   flock(ASSIGN, $LOCK_EX);
   undef $/;
   $assign_str = <ASSIGN>;
   flock(ASSIGN, $LOCK_UN);
   close(ASSIGN);
   
   $/="";
   @questions = split(/(<CN_Q.*>)/,$assign_str);
   chomp @questions;

   # Get the header
   my $test_header = shift @questions;
   my %test_params = TEST::unpack_stud_test_header($test_header);
   (%test_params) or
        ERROR::system_error('TEST','read_test','unpack stheader',
                            "$fname:$test_header");
   $self->{'Test Header'} = \%test_params;
   
   # Read in the question answers
   my $num_questions = grep(/<CN_Q/, @questions);
   for ($q_num=1; $q_num<=$num_questions; $q_num++) {
       $cn_q = shift @questions;
       %q_info = TEST::unpack_stud_question_header($cn_q);
       (%q_info) or
            ERROR::system_error('TEST','read_test','unpack qheader',
                                "$fname:$cn_q");
       $q_info{'ANS'} = shift @questions;
       # Remove beginning and ending whitespace
       $q_info{'ANS'} = CN_UTILS::remove_spaces($q_info{'ANS'});
       $name = $q_info{'NAME'};
       undef $q_info{'NAME'};
       $answers{$name} = { %q_info };
   }
   $self->{'Stud Answers'} = \%answers;
   return 1;
}

sub due_date_past {
   my ($self,$due_date) = @_;

   # Look in the header if no due date passed in
   if (!(defined $due_date)) {
       !(defined $self->{'Key Header'}) and
       	   $self->{'Key Header'} = $self->read();
       (defined $self->{'Key Header'}) or
            ERROR::system_error('TEST','due_date_past','read header',
                                "$self->{'Dev Root'}/options");
       $due_date = $self->{'Key Header'}{'DUE'};
   }

   # Get approx # of due days
   # If no due date, assigns are never late
   my ($due_hr, $due_min, $due_rest) = split(/:/,$due_date);
   if ($due_hr eq $due_date) {
      $due_hr = 0; $due_min = 0;
   } else {
      $due_date = $due_rest;
   }
   my ($due_mon, $due_day, $due_year) = split(/\//,$due_date);
   !$due_mon and
       return 0;
   $due_tot = $due_day + (31 * $due_mon) + ($due_year * 12 * 31);

   # Get approx # of current days
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   $mon+=1;
   $year+=1900;
   # Check for year 2000+. This check was in but not needed. (12/1/98)
   #($year < 1996) and 
   #    $year+=100;
   $cur_tot = $mday + ($mon * 31) + ($year * 12 * 31); 
   # convert both to minutes
   $cur_tot = 60 * (24 * $cur_tot + $hour) + $min;
   $due_tot = 60 * (24 * $due_tot + $due_hr) + $due_min;
   return ($cur_tot > $due_tot);
}

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $escaped_asn_name = CGI::escape($asn_name);
   my $escaped_stud_name = CGI::escape($stud_name);

   # Set input record separator and read the file
   $/ = "\n";

   my $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/graded/$escaped_asn_name";
   my $text = '';
   my $pr = '-';
   if (-e $path) {
       open(ASN,"<$path") or
           ERROR::system_error("TEST","get_score","open",$path);
       flock(ASN,$LOCK_EX);
       my $test_header = <ASN>;
       flock(ASN,$LOCK_UN);
       close(ASN);
       my %scores = TEST::unpack_stud_test_header($test_header);
       (%scores) or
            ERROR::system_error('TEST','get_score','unpack stheader',
                                "$path:$test_header");
       $tp = $scores{'TP'};
       $pr = $scores{'PR'};
       my $seen = $scores{'SEEN'};
       if (defined $seen) {
          $text .= "<BR>First Seen on $seen";
       }
       my $subdate = $scores{'SUBDATE'};
       if (defined $subdate) {
          $text .= "<BR>Submitted on $subdate";
       }
       my $date = CN_UTILS::getTime($path); 
       if ($scores{'SUBMIT'} == 2) {
         $pr = '?';
         $text .= " (awaiting grading by instructor)<BR>";
       } else {
         $text .= "<BR>Graded on $date<BR>";
       }
       $text = "<B>$asn_name:</B> $pr/$tp$text";
  }
   else { 
       $path = "$cls->{'Root Dir'}/assignments/$escaped_asn_name/options";
       open(ASN,"<$path") or
           ERROR::system_error('TEST','read','open',$path);
       my $adata = <ASN>;
       close(ASN);
       $adata =~ m/<CN_ASSIGN.*\sTP="?(\d+)/i;
       $tp = $1;
       $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/ungraded/$escaped_asn_name";
       if (-e $path) {
           my $date = CN_UTILS::getTime($path);
           open(ASN,"<$path") or
               ERROR::system_error('TEST','read','open',$path);
           my $adata = <ASN>;
           close(ASN);
           if ($adata =~ /SUBMIT=0/) {
               $text .= "(seen on $date but not yet submitted)<BR>";
           } else {
               $pr = '*';
               $text .= "(submitted on $date but not yet graded)<BR>";
           }
       } else {
           $text .= "(not seen)<BR>";
       }
       $text = "<B>$asn_name:</B> $pr/$tp $text";
   }

   return ($text,$tp,$pr);
}

sub print_test_header {
   my ($title,$window) = @_;
   (!defined $window) and $window = '_top';
print <<"HEADER";
Content-type: text/html
Window-target: $window

<HTML>
<HEAD>
<TITLE>$title</TITLE>
<base href="/">
</HEAD>
<BODY $GLOBALS::BGCOLOR>
<CENTER><H3>$title</H3></CENTER>
HEADER
}

sub print_base_header {
   my ($self,$window) = @_;
   (!defined $window) and $window = '_top';
   #my $base = "$GLOBALS::SECURE_ROOT\/$GLOBALS::SRM_ALIAS$self->{'Dev Root'}\/";
   my $base = "$GLOBALS::SECURE_ROOT\/";
   $base =~ s/\/local1\/classnet//;
   $base =~ s/%/%25/g;
print <<"HEADER";
Content-type: text/html
Window-target: $window

<HTML>
<HEAD>
<TITLE>$self->{'Name'}</TITLE>
</HEAD>
<BODY $GLOBALS::BGCOLOR>
<CENTER><H3>$self->{'Name'}</H3></CENTER>
HEADER
}

sub get_runtime_values {
    my ($self) = @_;
    # default is to return nothing
    return '';
}

sub source {
    my ($self) = @_;
    my $src = ASSIGNMENT::source($self);
   my $b;
   my $nb = $self->block_count();
   for ($b = 1; $b <= $nb; $b++) {
       # Read in block header <CN_BLOCK...>
       %params = $self->read_block($b,1);
       chomp ($params{'cn_block'});
       my $txt = CN_UTILS::remove_spaces($params{'btext'});
       $src .= "$params{'cn_block'}\n$txt\n";
       $nq = $self->question_count($b);
       for ($q = 1; $q <= $nq; $q++) {
       	   # Read in question header <CN_Q ...>
       	   %params = $self->read_question($b,$q,1);
       	   chomp ($params{'cn_q'});
           my $txt = CN_UTILS::remove_spaces($params{'qtext'});
           $src .= "$params{'cn_q'}\n$txt\n";
           my $txt = CN_UTILS::remove_spaces($params{'feedback'});
           $src .= "<CN_FEEDBACK>\n$txt\n";
       }
       $src .=  "</CN_BLOCK>\n";
   }
   return $src;
}

sub upload {
    my ($self,$url) = @_;

    my $hfile = ASSIGNMENT::upload($self,$url);
    if ($hfile =~ /\s*<CN_BLOCK/) {
        $self->uploadCN($hfile);
    } else {
        $self->uploadHTML($hfile);
    }
}

sub uploadCN {
    my ($self,$hfile) = @_;
    my @blocks = split(/<\s*\/CN_BLOCK\s*>\s*/,$hfile);
    my $b = 0;
    foreach $block (@blocks) {
        my $header = '';
        $block =~ s/(<\s*CN_BLOCK[^>]*>)/eval { $header = $1; ''}/e;
        my %params = unpack_block_header($header);
        $b++;
        if (!%params) {
            $self->delete();
            $header =~ s/</&lt/;
            ERROR::user_error($ERROR::NOTDONE,"upload. Check block $b:<BR><B>$header</B>");
            exit(0);
        }
        ($b > 1) and $self->insert_block($b);
        my @questions = split(/<\s*CN_Q/,$block);
        $params{'btext'} = shift @questions;
        $self->write_block($b,%params);
        my $q = 0;
        foreach $quest (@questions) {
            my $header = '';
            $quest =~ s/([^>]*>)/eval { $header = $1; ''}/e;
            my %params = unpack_question_header("<CN_Q$header");
            $q++;
            if (!%params) {
                $self->delete();
                ERROR::user_error($ERROR::NOTDONE,"upload. Check block $b, question $q:<BR><B>&ltCN_Q $header</B>");
                exit(0);
            }
            ($q > 1) and $self->insert_question($b,$q,%params);
            my @text = split(/<\s*CN_FEEDBACK\s*>/,$quest);
            $params{'qtext'} = $text[0];
            (defined $text[1]) and $params{'feedback'} = $text[1];
            $self->write_question($b,$q,%params);
        }
    }
}

sub uploadHTML {
    my ($self,$hfile) = @_;

    @questions = split(/<HR>/,$hfile);
    # throw away stuff before first <HR>
    shift @questions;
    $b = 0;
    foreach $quest (@questions) {
        #%params = unpack_block_header(<CN_BLOCK PTS=0/1>);
        $params{"TP"} = 1;
        $params{"PP"} = 0;
        $b++;
        ($b > 1) and $self->insert_block($b);
        $params{'btext'} = '';
        $self->write_block($b,%params);
        $qhdr = "<CN_Q>";
        $i = 0;
        if ($quest =~ s/<INPUT[^>]*TYPE=\"?RADIO\"?[^>]*>/eval {$i++;"<?>"}/eig) {
           $qhdr = "<CN_Q TYPE=CHOICE N=$i>";
        }
        if ($quest =~ s/<INPUT[^>]*TYPE=\"?CHECKBOX\"?[^>]*>/eval {$i++;"<?>"}/eig) {
           $qhdr = "<CN_Q TYPE=MULTIPLE N=$i>";
        }
        if ($quest =~ s/<INPUT(\s*NAME=\"?\S*\"?|\s*TYPE=\"?TEXT\"?|\s*SIZE=\"?(\d+)\"?)+\s*>/eval
           { $i = defined $2?$2:5;
             "<?>    <\/?>"
           }/eig) {
           $qhdr = "<CN_Q TYPE=BLANK JUDGE=NOJUDGE N=$i>";
        }
        if ($quest =~ s/<TEXTAREA(\s*ROWS=\"?(\d+)\"?|\s*COLS=\"?(\d+)\"?)+[^>]*>/<?>/ig) {
           $quest =~ s/<\/TEXTAREA>/<\/?>/ig;
           $r = defined $2?$2:5;
           $c = defined $3?$3:50;
           $qhdr = "<CN_Q TYPE=ESSAY ROWS=5 COLS=50>";
        }
        if ($quest =~ s/<SELECT[^>]*>/<?>/ig) {
           $quest =~ s/<OPTION>/eval { $i++; "<?>"}/eig;
           $quest =~ s/<OPTION SELECTED>/eval { $i++; "<?>"}/eig;
           $quest =~ s/<\/SELECT>/<\/?>/ig;
           $qhdr = "<CN_Q TYPE=OPTION N=$i>";
        }
        $quest =~ s/<\/FORM>//ig;
        $quest =~ s/<\/BODY>//ig;
        $quest =~ s/<\/HTML>//ig;
        my %params = unpack_question_header($qhdr);
        $params{'qtext'} = "$quest\n<CN_FEEDBACK>\n";
        $qtext = $params{'qtext'};
        $self->write_question($b,1,%params);
    }
}

sub get_stats {
    my ($self,$stats,$tot) = @_;
    my $name = $self->{'Name'};
    my $type;

    # Has key been read or constructed? 
    # Need key for differentiating question types
    $self->{'Key'} or $self->read_key();
    my $ans_key = $self->{'Key'};

    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $answers = $self->{'Stud Answers'};
        # if there are categories, then get the subcategory stat tables
        foreach $cat (split(/,/,$self->{'Categories'})) {
            foreach $key (keys %{$answers}) {
    	        $key =~ m/(\d+).(\d+)/;
                if ($1 eq $cat) {
    	            $type = $ans_key->{"$1.$2"}{'Question Type'};
                    if ($type =~ m/ESSAY/i || 
                        $type =~ m/BLANK/i ||
                        $type =~ m/MULTIPLE/i) {
		           ERROR::user_error($ERROR::NOTDONE,"categorize on ESSAY, BLANK or MULTIPLE questions.");
                    }
                    my $ans = $answers->{$key}{'ANS'};
                    if (!defined $stats->{$ans}) {
                       my %st = {};
                       $stats->{$ans} = \%st;
                    }
                    $stats = $stats->{$ans};
                    break;
                }
            }
        }
        foreach $key (keys %{$answers}) {
    	    $key =~ m/(\d+).(\d+)/;
    	    $type = $ans_key->{"$1.$2"}{'Question Type'};
            $ans = $answers->{$key}{'ANS'};
            if (defined $stats->{$key}) {
    	    	if ($type =~ m/ESSAY/i) {
    	    	    (length($ans) > 0) and
    	    	    	$stats->{$key} .= $ans . "<BR><HR>";
        	} elsif (defined $stats->{$key}{$ans}) {
                    $stats->{$key}{$ans}++;
                } else {
                    $stats->{$key}{$ans} = 1;
                }
            } else {
    	    	if ($type =~ m/ESSAY/i) {
    	    	    $stats->{$key} = "";
    	    	    (length($ans) > 0) and
    	    	    	$stats->{$key} = $ans . "<BR><HR>";
        	} else { 
                    my %cnt = {};
                    $cnt{$ans} = 1;
                    $stats->{$key} = \%cnt;
    	    	}
            }
        };
        my $pr = $self->{'Test Header'}{'PR'};
        if (defined $tot->{$pr}) {
            $tot->{$pr}++;
        } else {
            $tot->{$pr} = 1;
        }
    }
}

sub pushstats {
    my ($slist,$prefix,$cats,$stats) = @_;
    my @catlist = @{$cats};
    if ($#catlist >= 0) {
       my $catname = shift(@catlist);
       foreach $key (keys %{$stats}){
           pushstats($slist,"$prefix <TR><TD>$catname</TD><TD>$key</TD></TR>",\@catlist,$stats->{$key});
       }
    } else {
       push(@{$slist},$prefix,$stats);

    }
}

sub format_stats {
    my ($self,$st,$tot) = @_;
    $self->read_key();
    my $key = $self->{'Key'};
    my $form = '<FORM>';
    my $question;
    # Read all blocks and questions
    !($self->{'bl_q'}) and
        $self->read_all();
    my $bl_q = $self->{'bl_q'};
    my %values = $self->get_runtime_values();
    my $nb = $self->block_count();
    my @slist = ();
    my @clist = split(/,/,$self->{'Categories'});
    pushstats(\@slist,"",\@clist,$st);
    for ($i = 0; $i <= 2 * $#slist; $i++) {
       my $label = shift(@slist);
       my $stats = shift(@slist);
       if ($label ne '') {
           $form .= "<TABLE ALIGN=CENTER BGCOLOR=#CCCCCC BORDER=1><TR><TH>Question</TH><TH>Answer</TH></TR>$label</TABLE>";
       }
       for ($b = 1; $b <= $nb; $b++) {
           $form .= $self->check_java("$bl_q->{$b}{'btext'}","play");
           my $nq = $self->question_count($b);
           for ($q = 1; $q <= $nq; $q++) {
               my $row1 = '<TH ALIGN=CENTER>Answer</TH>';
               my $row2 = '<TD ALIGN=CENTER>Count</TD>';
               my $root = "$b.$q";
               $ans = $key->{$root}{'ANS'};
               my $key_ans = $bl_q->{$root}{'ANS'};
               if (%values) {
                   $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
               }

    	       #set up blank and multiple key answers for replace_placeholders
    	       #***NOTE!! This assumes that any runtime values have been previously escaped properly!!***
               if ( ($key->{$root}{'Question Type'} =~ /BLANK/i)
    	    	     or($key->{$root}{'Question Type'} =~ /MULTIPLE/i) )   {
       	    	   my @key_answers = split(/,/, $key_ans);
       	    	   grep {s/%22/"/g; s/%2C/,/g} @key_answers;
    	    	   $key_ans = join("%2C",@key_answers);
    	       }
    	    
               if ($key->{$root}{'Question Type'} =~ /ESSAY/i) {
    	    	   #$question = $self->replace_placeholders($stats->{$root},$b,$q,%{$bl_q->{$root}});
                   $question = $stats->{$root};
               }
    	       else {
    	    	   $question = $self->replace_placeholders($key_ans,$b,$q, 
                                                       %{$bl_q->{$root}});
    	       }
               if ($key->{$root}{'Question Type'} =~ /BLANK/i) {
                   $n = $key->{$root}{'N'};
                   for ($i = 1; $i <= $n; $i++) {
                       my $blnk = "$root.$i";
                       if (defined $stats->{$blnk}) {
                           foreach $ans (keys %{$stats->{$blnk}}) {
                               $row1 .= "<TH ALIGN=CENTER>$ans</TH>\n";
                               $row2 .= "<TD ALIGN=RIGHT>$stats->{$blnk}{$ans}</TD>\n";
                           }
                       }
                   }
               } elsif ($key->{$root}{'Question Type'} =~ /MULTIPLE/i) {
                   $n = $key->{$root}{'N'};
                   for ($i = 1; $i <= $n; $i++) {
                       my $blnk = "$root.$i";
                       my $nm = $stats->{$blnk}{'1'};
                       (! defined $nm) and $nm = 0;             
                       $row1 .= "<TH ALIGN=CENTER>$i</TH>\n";
                       $row2 .= "<TD ALIGN=RIGHT>$nm</TD>\n";
                   }
               } elsif ($key->{$root}{'Question Type'} =~ /ESSAY/i) {
    	    	   $question =~ s/(<textarea)/<br><b>Student Answers:<\/b><br>$1/i;
                   $row1 = "<TH ALIGN=CENTER>Essay</TH>\n";
                   $row2 = "<TD ALIGN=CENTER>N/A</TD>\n";
               } else {
                   if (defined $stats->{$root}) {
                       foreach $ans (keys %{$stats->{$root}}) {            
                           $row1 .= "<TH ALIGN=CENTER>$ans</TH>\n";
                           $row2 .= "<TD ALIGN=RIGHT>$stats->{$root}{$ans}</TD>\n";
                       }
                   }
               }
               $form .= "<B>$b)</B> $question<P><TABLE BORDER=1 BGCOLOR=#FFFFFF>$row1<TR>$row2</TABLE><P>\n";
           }
       }
    }
    $form .= '</FORM>';
    my $fname = "$$.dat";
    open(DATA,">$fname");
    my $max = 0;
    foreach $v (keys %{$tot}) {
        my $n = $tot->{$v}; 
        print DATA "$v $n\n";
        ($n > $max) and $max = $n;
    }
    close(DATA);
    my $tp = $self->{'Key Header'}{'TP'};
    TEST::print_test_header("Statistics");
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
$form
HEAD
    CN_UTILS::print_cn_footer();

}

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = "$sname";
    my $name = $self->{'Name'};
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $answers = $self->{'Stud Answers'};
        my $nb = $self->block_count();
        for ($i=1;$i <= $nb; $i++) {
            my $key = "$i.1";
            if (defined $answers->{$key}{'ANS'}) {
                $ans = $answers->{$key}{'ANS'};
                $body .= "\t$ans";
            } else {
                my $j = 1;
                $body .= "\t";
                while (defined $answers->{"$key.$j"}{'ANS'}) {
                    $ans = $answers->{"$key.$j"}{'ANS'};
                    $body .= "|$ans";
                    $j++;
                }
            }
        }
    }
    $body .= "\n";
}

# Modify the applet params
# SRM_ALIAS must be defined in srm.conf of ClassNet's httpd server
#    - this allows server document retrieval in other directories
# BASE HREF must be added to the document
# All % signs for codebase must be converted to hex rep. of %25
sub check_java {
    my ($self,$btext,$mode) = @_;
    if ($btext =~ /<APPLET/i) {
	my $code_base = '';
        # add /.develop/ if not published
        if ($self->{'Dev Root'} =~ /.develop/) {
            $code_base = "$GLOBALS::SRM_ALIAS";
        }
	else {
            $code_base = "$GLOBALS::SRM_ALIAS";
	}
        $code_base =~ s/%/%25/g;
        $btext =~ s/<APPLET/<APPLET/i;
        my $param_str =<<"PARAMS";
<param name="mode" value="$mode">
<param name="filePath" value="$self->{'Java Dir'}">
PARAMS
        $btext =~ s/<\/APPLET>/$param_str<\/APPLET>/i;
    }
    return $btext;
}

1;




