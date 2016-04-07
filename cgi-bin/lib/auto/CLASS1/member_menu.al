# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

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

1;
