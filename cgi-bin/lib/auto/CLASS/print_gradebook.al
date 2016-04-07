# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

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
        ASSIGNMENT::print_listbox($self,'published','MULTIPLE');
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
        ASSIGNMENT::print_listbox($self,'published','MULTIPLE');
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

1;
