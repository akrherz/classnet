# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

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

1;
