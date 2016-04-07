package TESTEDITOR;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader, EDITOR);
#@ISA = qw( EDITOR );
#
# handles editing of tests
#

#########
=head1 TESTEDITOR

=head1 Methods:

=cut
#########


require TEST;
require FORECAST;
require EDITOR;
require EVAL;

__END__

#########################################
=head2 open()

=over 4

=item Description
start the editor for this assignment

=item Params
none

=item Returns
none

=back

=cut

sub open {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $cls = $asn->{'Class'};
    my $develop = "$cls->{'Root Dir'}/assignments/.develop";
    my $flag = "$develop/.flag";
    # remove flag to tell when in editor
    if (-e $flag) {
        unlink $flag;
    }
    # since answers are likely to change, delete key
    # it will be regenerated when grading occurs
    $asn->delete_key();
    $url = $self->URL_edit_string();
    # create document to define window frames
    # the window is divided into three frames
    #---------------------------
    #| listing |    editor     |
    #|         |               |
    #|         |               |
    #---------------------------
    #|     help                |
    #---------------------------
    print <<"FRAMES";
Content-type: text/html

<HTML>
<HEAD>
  <TITLE>Test Editor</TITLE>
</HEAD>
<frameset rows="*,50">
  <frameset cols="*,2*">
    <frame name="listing" src="$url&suboption=List">
    <frame name="editor" src="$GLOBALS::SERVER_ROOT/editor_frame.html">
  </frameset>    
  <frame name="help" src="$GLOBALS::SERVER_ROOT/asn_edit_help.html">
<noframes>
<BODY>
  Sorry! This document cannot be viewed without a frames-capable
  browser.
</BODY>
</noframes>
</frameset>
</HTML>
FRAMES
}

#########################################
=head2 command()

=over 4

=item Description
Process an edit command

=item Params
none

=item Returns
none

=back

=cut

sub command {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $query = $asn->{'Query'};
    $_ = $query->param('suboption');
FRAME: {
    /^listing/ &&
        do {
            $self->listing();
            last FRAME;
           };

    /^writing/ &&
        do {
            $self->writing($query->param('block'),$query->param('question'));
            last FRAME;
           };

    /^List/ &&
        do {
            $self->print_listing();
            last FRAME;
           };

    /^Editor/ &&
        do {
            CN_UTILS::print_cn_header('Editor');
            CN_UTILS::print_cn_footer();
            last FRAME;
           };

    /^Help/ &&
        do {
            CN_UTILS::print_cn_header('Help');
            CN_UTILS::print_cn_footer();
            last FRAME;
           };
    $self->print_help($_);
    }
}

#########################################
=head2 print_edit_header()

=over 4

=item Description
Prints the HTML header for the edit frame

=item Params
none

=item Returns
none

=back

=cut

sub print_edit_header {
    print <<"HEADER";
Content-type: text/html
Window-target: editor

<HTML>
<HEAD>
<META HTTP-EQUIV="Window-target" CONTENT="editor">
</HEAD>
<BODY $GLOBALS::BGCOLOR>
HEADER
}

#########################################
=head2 print_help($msg)

=over 4

=item Description
Prints $msg in help frame

=item Params
$msg: A string message

=item Returns
none

=back

=cut

sub print_help {
    my ($self,$msg) = @_;
    print <<"HELP";
Content-type: text/html
Window-target: help

<HTML>
<BODY BGCOLOR=#ffffff>
$msg
</BODY>
</HTML>
HELP
    exit(0);
}

#########################################
=head2 listing()

=over 4

=item Description
Handle the listing frame commands

=item Params
$query: CGI query object

=item Returns
none

=back

=cut

sub listing {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $query = $asn->{'Query'};
    my $cls = $asn->{'Class'};
    my $dir = $asn->{'Dev Root'};
    my $develop = "$cls->{'Root Dir'}/assignments/.develop";
    my $clipb = "$develop/.clipb"; 
    my $clipq = "$develop/.clipq"; 
    my $flag = "$develop/.flag";
    if ($query->param('back')) {
       if (!($asn->{'Dev Root'} =~ /.develop/)) {
           $asn->make_key();
       }
       ASSIGNMENT::print_menu($cls,$asn->{'Member'});
       unlink $flag;
       exit(0);
    }
    if ($query->param('listing') eq 'View') {
       my $form = $asn->get_new_form('instructor','nosubmit');
       $asn->print_base_header('View');
       print "<HR>$form";
       CN_UTILS::print_cn_footer();
       exit(0);
    }

    if (!defined $query->param('section')) {
        $self->print_help('Click on a <b>section</b> in the Listbox first.');
    }
    $section = $query->param('section');
    if ($section =~ /^(\d+)[\.](\d+)/) { 
	$b = $1; $q = $2;
        $type = 2;
    } elsif ($section =~ /^(\d+)[\ ]/) {
        $b = $1;
        $type = 1;
    } else {
        $type = 0;
    }
    $_ = $query->param('listing');
    if (-e $flag) {
        $self->print_help("You must <b>Cancel</b> or <b>Save</b> in the section editor before using $_.");
    }
    SWITCH: {
        /^Edit/ && 
            do { # edit selection
                open(EDIT_FLAG,">$flag");
                close(EDIT_FLAG);
                if ($type == 0) {
                    $self->edit_assignment();
                } elsif ($type == 1) {
                    $self->edit_block($b);
                } else {
                    $self->edit_question($b,$q);
                }
                last SWITCH;
               };

        /^Add/ && 
            do { # add new block/question after selection
                if ($type == 0) {
                    # if assignment selected, add block to end of list
                    $type = 1;
                    $b = $asn->block_count() + 1;
                } elsif ($type == 1) {
                    # if block selected, add question to end of list
                    $type = 2;
                    $q = $asn->question_count($b) + 1;
                } else {
                    # if question selected, add question after selection
                    $q++;
                }
                if ($type == 1) {
                    $asn->insert_block($b);
                } else {
                    $asn->insert_question($b,$q);
                }
                $self->print_listing();
                last SWITCH;
               };

        /^Cut/ && 
            do { # move selection to clipboard (.clipb or .clipq)
                if ($type == 0) {
                    $self->print_help('You may only <b>edit</b> an assignment or insert a section.');
                } elsif ($type == 1) {
                    my $nb = $asn->block_count();
                    if ($nb == 1) {
                        $self->print_help('Every assignment must have at
least one block. Delete the assignment instead.');
                    }
                    system "rm -r $clipb";
                    system "cp -r $dir/$b $clipb";
                    $asn->delete_block($b);
                } else {
                    my $nq = $asn->question_count($b);
                    if ($nq == 1) {
                        $self->print_help('Every block must have at least one question. Delete the block instead.');
                    }
                    system "cp $dir/$b/$q $clipq";
                    $asn->delete_question($b,$q);
                }
                $self->print_listing();
	        last SWITCH;
	       }; 

        /^Copy/ && 
            do { # copy selection to clip buffer
                if ($type == 0) {
                    $self->print_help('You may only <b>edit</b> an assignment or insert a section.');
                }
                if ($type == 1) {
                    (-e $clipb) and system "rm -r $clipb";
                    system "cp -r $dir/$b $clipb";
                } else {
                    (-e $clipq) and unlink $clipq;
                    system "cp $dir/$b/$q $clipq";
                }
                $self->print_help('Copy complete.');
                last SWITCH;
               };

        /^Paste/ && 
            do { # copy cut buffer (if any) at selection
                if ($type == 0) {
                    $self->print_help("You can't paste there.");
                } 
                if ($type == 1) {
                    # insert block at location. Copy clipb if exists.
                    $asn->insert_block($b);                    
                    if (-e "$clipb") {
                        system "rm -r $dir/$b";
                        system "cp -r $clipb $dir/$b";
                    }
                } else {
                    # insert question at location; replace with clipq
                    $asn->insert_question($b,$q);
                    if (-e "$clipq") {
                        system "cp $clipq $dir/$b/$q";
                    }
                }
                $self->print_listing();
                last SWITCH;
               };

        $self->print_help("Bad option: $_");
    }
}

#########################################
=head2 writing($b,$q)

=over 4

=item Description
Write out appropriate section

=item Params
$b: block number

$q: question number

=item Returns
none

=back

=cut

sub writing {
    my ($self,$b,$q) = @_;
    my $asn = $self->{'Assignment'};
    my $cls = $asn->{'Class'};
    my $develop = "$cls->{'Root Dir'}/assignments/.develop";
    my $flag = "$develop/.flag";
    my $query = $asn->{'Query'};
    if ($query->param('back')) {
       unlink $flag;
       $self->print_edit_header();
       $self->print_footer();
       exit(0);
    }
    $_ = $query->param('section_type');
    SWITCH: {
        /^asn/  &&
           do  {
                 if ($query->param('duedate')) {
                     if (($query->param('duedate') =~ /^(\d{2}:\d{2}:)?([01]\d?)\/([0-3]\d?)\/(\d{4})$/)) {
                         if (($2 == 2 and $3 > 29) or ($3 > 31)) {
                             $self->print_help('The value for days is too large.');
                         }
                         my $tm = $1;
                         if ($tm =~ /(\d{2}):(\d{2}):/) {
                             if ($1 > 23 or $2 > 59) {
                                 $self->print_help('The value for hours or minutes is too large.');
                             }
                         }
                     } else {
                         $self->print_help('Enter date in the form mm/dd/yyyy (e.g. 01/05/1997) or hh:mm:mn/dd/yyyy (e.g. 13:30:01/05/1997)');        
                     }
                 }
                 my %params = {};
                 $params{'Assignment Type'} = $query->param('Assignment Type');
                 ($query->param('duedate')) and 
                     $params{'DUE'} = $query->param('duedate');
                 ($query->param('password')) and 
                     $params{'PASSWORD'} = $query->param('password');
                 (defined $query->param('fill')) and 
                     $params{'FILL'} = 1;
                 (defined $query->param('view')) and 
                     $params{'VIEW'} = 1;
                 (defined $query->param('mult')) and 
                     $params{'MULT'} = 1;
                 if ($query->param('rand') eq 'vers') { 
                     $params{'VERS'} = $query->param('versions');
                 } else {
                     $params{'RAND'} = 1;
                 }
                 $params{'TP'} = $query->param('TP');
                 unlink $flag;
                 $asn->write(%params);
                 $asn->put_extra_fields($query);
                 if (defined $query->param('publish')) { 
                     $asn->publish();
                 } else {
                     $asn->unpublish();
                 }
                 last SWITCH;
           };

        /^blk/  &&
           do  {
                 my %params = {};
                 my $tc = $query->param('tcredit');
                 my $pc = $query->param('pcredit');
                 if (($tc =~ /\./) || ($pc =~ /\./)) {
                     $self->print_help('Points must be whole numbers.');
                 }
                 if ($tc =~ /\s*(\d+)\s*/) {
                     $params{'TP'} = $1;
                     if ($pc =~ /\s*(\d+)\s*/) {
                         $params{'PP'} = $1;
                         if ($params{'PP'} > $params{'TP'}) {
                             $self->print_help('Partial points must be less than or equal to total points.');
                         }
                     } elsif (!($pc =~ /\s*/)) {
                         $self->print_help('Enter a number or leave Partial blank.');
                     }
                 } elsif ($tc =~ /\s*/) {
                     $self->print_help('Enter a number or leave Total blank.');
                 }
                 $params{'Name'} = $query->param('name');
                 $params{'btext'} = $query->param('btext');
                 unlink $flag;
                 $asn->write_block($b,%params);
                 last SWITCH;
           };

        /^qst/  &&
           do  {
                 my $ldelim = '&lt;?&gt;';
                 my $rdelim = '&lt;/?&gt;';
                 my %params = {};
                 $params{'Question Type'} = $query->param('Question Type');
                 $ans = $query->param('ANS');
                 my $qtext = CN_UTILS::remove_spaces($query->param('qtext'));
                 $params{'qtext'} = $qtext;
                 if ($params{'Question Type'} eq 'CHOICE') {
                     for ($n = 0; $qtext =~ /<\?>/g; $n++) {};
                     if ($n == 0) {
                         $self->print_help('For CHOICE, use $ldelim in front of each answer.');
                     }
                     unless (($ans eq '') or
                         ($ans =~ /{\s*\w+\s*}/) or 
                         ($ans >= 1 and $ans <= $n)) {
                         $self->print_help("For CHOICE, answer should be a number between 1 and $n.");
                     };
                 } elsif ($params{'Question Type'} eq 'LIKERT') {
                     for ($n = 0; $qtext =~ /<\?>/g; $n++) {};
                     if ($n == 0) {
                         $self->print_help('For LIKERT, use $ldelim to mark your choices.');
                     }
                     unless (($ans eq '') or
                         ($ans =~ /{\s*\w+\s*}/) or 
                         ($ans =~ /^\s*[+-]?\d+(\s*,\s*[+-]?\d+\s*)*\s*$/)) {
                         $self->print_help("For LIKERT, answer should be
blank or a list of numbers (weights) separated by commas.");
                     };
                 } elsif ($params{'Question Type'} eq 'BLANK') {
                     for ($i = 0; $qtext =~ /<\?>/g; $i++) {};
                     for ($n = 0; $qtext =~ /<\/\?>/g; $n++) {};
                     if ($i == 0 || $n == 0) {
                         $self->print_help("For BLANK, use $ldelim xxx
$rdelim to mark the location, size and initial value.");
                     }
                     if ($i != $n) {
                         $self->print_help("Mismatched delimiters (i.e. $ldelim or $rdelim).");
                     }
                     if ($i != split(/,/,$ans)) {
                         $self->print_help("The number of answers and blanks don't agree.");
                     }
                     $params{'N'} = $i;
                 } elsif ($params{'Question Type'} eq 'MULTIPLE') {
                     for ($i = 0; $qtext =~ /<\?>/g; $i++) {};
                     if ($i == 0) {
                         $self->print_help("For MULTIPLE, precede each option by a $ldelim.");
                     }
                     $params{'N'} = $i;
                 } elsif ($params{'Question Type'} eq 'ESSAY') {
                     for ($i = 0; $qtext =~ /<\?>/g; $i++) {};
                     for ($n = 0; $qtext =~ /<\/\?>/g; $n++) {};
                     if ($i !=1 || $n != 1) {
                         $self->print_help("For ESSAY, mark location
and size of editor by one pair of $ldelim...$rdelim.");
                     }
                     $params{'N'} = $i;
                 }
                 $params{'ANS'} = $ans;
                 $params{'feedback'} = CN_UTILS::remove_spaces($query->param('feedback'));
                 if ($query->param('rows') =~ /\s*(\d+)\s*/) {
                     $params{'ROWS'} = $1;
                     ($params{'Question Type'} eq 'BLANK') and
                         $params{'ROWS'} = 1;
                 }
                 if ($query->param('cols') =~ /\s*(\d+)\s*/) {
                     $params{'COLS'} = $1;
                 }
                 if ($query->param('jtype') eq 'numeric') {
                     $judge = 'NUM';
                 } else {
                     if ($query->param('exact')) {
                         $judge .= $judge? ',EXACT':'EXACT';
                     } else {
                         $judge .= $judge? ',NOEXACT':'NOEXACT';
                         ($query->param('caps')) and $judge .= ',CAPS';
                         ($query->param('spell')) and $judge .= ',SPELL';
                         ($query->param('punc')) and $judge .= ',PUNC';
                         ($query->param('order')) and $judge .= ',ORD';
                         ($query->param('count')) and $judge .=',CNT';
                     }
                 }
                 $params{'JUDGE'} = $judge;
                 if (defined $query->param('view')) {
                     TEST::print_test_header('Test Question','View');
                     print "<FORM METHOD=POST>\n";
                     print $asn->replace_placeholders("",$b,$q,%params);
                     print "</FORM>\n";
                     $self->print_footer();
                     exit(0);
                 }
                 unlink $flag;
                 $asn->write_question($b,$q,%params);
                 last SWITCH;
           };
    };
    $self->print_edit_header();
    $self->print_footer();
}

#########################################
=head2 edit_assignment()

=over 4

=item Description
Edit the assignment options file

=item Params
none

=item Returns
ASSIGNMENT object

=back

=cut

sub edit_assignment {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my %params = $asn->read();
    my $atype = $params{'Assignment Type'};
    if ($params{'VERS'} > 0) {
        $nver = $params{'VERS'};
        $rand = 0;
    } else {
        $nver = '';
        $rand = 1;
    }
    $extra_fields = $asn->get_extra_fields();
    $ansall  = $EDITOR::checked[$params{'FILL'}];
    $letview = $EDITOR::checked[$params{'VIEW'}];
    $mult    = $EDITOR::checked[$params{'MULT'}];
    $duedate = $params{'DUE'};
    $pass = $params{'PASSWORD'};
    $tp = $params{'TP'};
    $publish = $EDITOR::checked[!($asn->{'Dev Root'} =~ /.develop/)];
    $self->print_edit_header();
    $self->print_start_form();
    print <<"ASSIGN";
<INPUT TYPE=hidden NAME="Assignment Type" VALUE="$atype">
<INPUT TYPE=hidden NAME=section_type VALUE=asn>
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<INPUT TYPE=hidden NAME=TP VALUE=$tp>
<CENTER>
<H3>Assignment $asn->{'Name'}</H3>
(Type $atype)
<HR>
<H3>Question Selection</H3> 
<INPUT TYPE=radio NAME=rand VALUE=rand $EDITOR::checked[$rand]> Random
<INPUT TYPE=radio NAME=rand VALUE=vers $EDITOR::checked[!$rand]> Versions 
<INPUT TYPE=text NAME=versions SIZE=2 VALUE="$nver">
<HR>
<H3>Student Answer Options</H3>
<INPUT TYPE=checkbox NAME=fill VALUE=fill $ansall> Answers all questions
<INPUT TYPE=checkbox NAME=view VALUE=view $letview> View correct answers
<HR>
<H3>Due Date</H3>
(hh:mm:mn/dd/yyyy)<BR>
<INPUT TYPE=text NAME=duedate SIZE=16 VALUE=$duedate>
<HR>
<H3>Proctor Options</H3>
Password<BR>
<INPUT TYPE=password NAME=password SIZE=16 VALUE="$pass"><BR>
<INPUT TYPE=checkbox NAME=mult VALUE=mult $mult> Allow multiple tries 
<HR>
<INPUT TYPE=checkbox NAME=publish VALUE=Publish $publish> Publish 
<HR>
$extra_fields
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save>
<INPUT TYPE=reset  NAME=reset VALUE=Reset> 
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
ASSIGN
    $self->print_footer();
}

#########################################
=head2 edit_block($b)

=over 4

=item Description
Edit the block information

=item Params
$b: Block number

=item Returns
ASSIGNMENT object

=back

=cut

sub edit_block {
    my ($self,$b) = @_;
    my $asn = $self->{'Assignment'};
    my %params = $asn->read_block($b);

    $name = $params{'Name'};
    $pcredit = $params{'PP'};
    $tcredit = $params{'TP'};
    $btext = $params{'btext'};

    $self->print_edit_header();
    $self->print_start_form();
    print <<"BLOCK";
<INPUT TYPE=hidden NAME=section_type VALUE=blk>
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<INPUT TYPE=hidden NAME=block VALUE=$b>
<CENTER>
Name <INPUT TYPE=text SIZE=20 NAME=name VALUE="$name" MAXLENGTH=20>
<HR>
<H3>Credit</H3>
Total <INPUT TYPE=text SIZE=5 NAME=tcredit VALUE="$tcredit"> 
Partial <INPUT TYPE=text SIZE=5 NAME=pcredit VALUE="$pcredit">
<HR>
<H3>Preface</H3>
<TEXTAREA NAME=btext COLS=50 ROWS=10>
$btext
</TEXTAREA>
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save> 
<INPUT TYPE=reset  NAME=reset VALUE=Reset> 
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
BLOCK
    $self->print_footer();
}

#########################################
=head2 edit_question($b,$q)

=over 4

=item Description
Present form to edit the question data

=item Params
$b: Block number

$q: Question number

=item Returns
none

=back

=cut

sub edit_question {
    my ($self,$b,$q) = @_;
    my $asn = $self->{'Assignment'};
    %params = $asn->read_question($b,$q);
    $type = $params{'Question Type'};
    $ans = $params{'ANS'};
    $qtext = $params{'qtext'};
    $feedback = $params{'feedback'};
    $judge = $params{'JUDGE'};
    $istext = !($judge =~ /NUM/);
    #judging options
    $exact = (($judge =~ /EXACT/) and !($judge =~ /NOEXACT/));
    $spell = (($judge =~ /SPELL/) and !($judge =~ /NOSPELL/));
    $punc = (($judge =~ /PUNC/) and !($judge =~ /NOPUNC/));
    $order = (($judge =~ /ORD/) and !($judge =~ /NOORD/));
    $count = (($judge =~ /CNT/) and !($judge =~ /NOCNT/));
    $caps = (($judge =~ /CAPS/) and !($judge =~ /NOCAPS/));
    $rows = $params{'ROWS'};
    (!defined $rows) and $rows = 5;
    $cols = $params{'COLS'};
    (!defined $cols) and $cols = 50;

    $self->print_edit_header();
    $self->print_start_form();
    print <<"QUEST";
<INPUT TYPE=hidden NAME=section_type VALUE=qst>
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<INPUT TYPE=hidden NAME=block VALUE=$b>
<INPUT TYPE=hidden NAME=question VALUE=$q>
<CENTER><H2>Question $b.$q</H2>
<HR>
Type: 
<B>
<SELECT NAME="Question Type">
<OPTION $EDITOR::selected[$type eq 'CHOICE']>CHOICE
<OPTION $EDITOR::selected[$type eq 'BLANK']>BLANK
<OPTION $EDITOR::selected[$type eq 'ESSAY']>ESSAY
<OPTION $EDITOR::selected[$type eq 'OPTION']>OPTION
<OPTION $EDITOR::selected[$type eq 'LIST']>LIST
<OPTION $EDITOR::selected[$type eq 'MULTIPLE']>MULTIPLE
<OPTION $EDITOR::selected[$type eq 'LIKERT']>LIKERT
</SELECT>
</B>
<BR>
Answer: <INPUT TYPE=text NAME=ANS VALUE="$ans" SIZE=40><BR>
<HR>
<H3>Question Text</H3>
<TEXTAREA NAME=qtext ROWS=10 COLS=50>
$qtext
</TEXTAREA>
<HR>
<H3>Feedback</H3>
<TEXTAREA NAME=feedback ROWS=10 COLS=50>
$feedback
</TEXTAREA>
<HR>
<H3>Blank Judging Options</H3>
Type:
<INPUT TYPE=radio NAME=jtype VALUE=textual $EDITOR::checked[$istext]> Textual
<INPUT TYPE=radio NAME=jtype VALUE=numeric $EDITOR::checked[!$istext]> Numeric
<BR>
<H4>Textual Judging Enforcement</h4>
<INPUT TYPE=checkbox NAME=exact $EDITOR::checked[$exact]> Exact
<INPUT TYPE=checkbox NAME=caps $EDITOR::checked[$caps]> Capitals
<INPUT TYPE=checkbox NAME=spell $EDITOR::checked[$spell]> Spelling
<INPUT TYPE=checkbox NAME=punc $EDITOR::checked[$punc]> Punctuation
<BR>
<INPUT TYPE=checkbox NAME=order $EDITOR::checked[$order]> Word order
<INPUT TYPE=checkbox NAME=count $EDITOR::checked[$count]> Word count
<BR>(Only exact comparisons are currently implemented)
<HR>
<H3>Essay Editor Size</H3>
Rows: <INPUT TYPE=text NAME=rows VALUE="$rows" SIZE=3> 
Cols: <INPUT TYPE=text NAME=cols VALUE="$cols" SIZE=3>
<HR>
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save>
<INPUT TYPE=submit NAME=view VALUE=View> 
<INPUT TYPE=reset  NAME=reset VALUE=Reset> 
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
QUEST
    $self->print_footer();
}

#########################################
=head2 store_list()

=over 4

=item Description
Generate a list of block and question
lines, one from each file

=item Params
none

=item Returns
none

=back

=cut

sub store_list {
}

#########################################
=head2 print_listing()

=over 4

=item Description
print listing HTML

=item Params
none

=item Returns
none

=back

=cut

sub print_listing {
    my ($self) = @_;
    $asn = $self->{'Assignment'};
    $cname = $asn->{'Class'}->{'Name'};
    $aname = $asn->{'Name'};
    print <<"LIST";
Content-type: text/html
Window-target: listing

<HTML>
<HEAD>
  <TITLE>$title</TITLE>
</HEAD>
<BODY $GLOBALS::BACKGROUND $GLOBALS::BGCOLOR>
<CENTER><h2>Sections</h2></CENTER>
LIST
    $self->print_start_form();
    print <<"LIST";
<INPUT TYPE=hidden NAME=suboption VALUE=listing>
<CENTER>
<SELECT SIZE=15 NAME=section>
<OPTION>$aname
LIST
# get number of blocks
$nblk = $asn->block_count();
for ($b = 1; $b <= $nblk; $b++) {
    %params = $asn->read_block($b);
    print "<OPTION>$b $params{'Name'}\n";
    $nq = $asn->question_count($b);
    for ($q = 1; $q <= $nq; $q++) {
        print "<OPTION>$b.$q\n";
    }
}
print <<"FOOTER";
</SELECT>
<P>
<H4>
<INPUT TYPE=submit NAME=listing VALUE=Edit>
<INPUT TYPE=submit NAME=listing VALUE=Add>
<BR>
<INPUT TYPE=submit NAME=listing VALUE=Cut>
<INPUT TYPE=submit NAME=listing VALUE=Copy>
<INPUT TYPE=submit NAME=listing VALUE=Paste>
<BR>
<INPUT TYPE=submit NAME=listing VALUE=View>
<BR>
<INPUT TYPE=submit NAME=back VALUE="Assignments Menu">
</H4>
<P>
$GLOBALS::RED_BALL <a HREF="$GLOBALS::SERVER_ROOT/help/edit_test.html" target=Help>Help</a>
</CENTER>
</FORM>
</BODY>
</HTML>
FOOTER
}

1;
