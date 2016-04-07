# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub print_approval_list {
    my ($self,$inst) = @_;

    my @mem_list = $self->get_mem_names('requests');
    my $req_dir_root = $self->{'Root Dir'} . "/admin/members/requests";

    # Send the list
    CN_UTILS::print_cn_header("Approve Students");
    print qq|<CENTER><H3>$self->{'Name'}</H3></CENTER>\n|;
    print <<"START";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Enroll Request Members">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER>
<TABLE WIDTH="50%" BORDER>
<TR><TH>Name<TH>Email<TH>A Addresspprove<TH>Reject<TH>Retain</TR>
START
    foreach $name (sort @mem_list) {
        my $disk_uname = CGI::unescape($name);
        $disk_uname = CN_UTILS::get_disk_name($disk_uname);
        my $email = "";
        open(REQ_FILE, "<$disk_uname") or 
            &ERROR::system_error("INSTRUCTOR","approval","Open",$disk_uname);
        while (<REW_FILE>) {
           chop;
       	   my ($option, $value) = split(/=/);
       	   if ($option eq 'Email Address') {
              $email = $value;
           }
        }
        close(REQ_FILE);
       	print qq|<TR ALIGN=CENTER><TD>$name|;
       	print qq|<TD><a href="email:$email|">$email</a>;
	print qq|<TD><INPUT TYPE=radio NAME="STU_$name" VALUE="app" CHECKED>|;
       	print qq|<TD><INPUT TYPE=radio NAME="STU_$name" VALUE="rej">|;
       	print qq|<TD><INPUT TYPE=radio NAME="STU_$name" VALUE="ret">|;
        print qq|</TR>|;
    }
    print <<"END";
</TABLE>
</CENTER>
<P>
Approve will add the student to the class.<BR>
Reject will delete the request and not add the student.<BR>
Retain will keep the request for future consideration.
<H4><CENTER><INPUT TYPE=submit Value=Submit></CENTER></H4><p>
</FORM>
END
    CN_UTILS::print_cn_footer("approve_students.html");
}

1;
