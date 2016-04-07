# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

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

1;
