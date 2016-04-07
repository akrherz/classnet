# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub print_member_list {
    my ($self) = @_;

    %inst_info_list = $self->get_cls_mem_info('instructor');
    %stud_info_list = $self->get_cls_mem_info('student');

    # Send the list
    CN_UTILS::print_cn_header("Membership List");
    print qq|<CENTER><H3>$self->{'Name'}</H3></CENTER>|;
    print qq|<CENTER><H2>Instructors</H2></CENTER><DL>|;
    foreach $key (sort (keys %inst_info_list)) {
       	# Change to verbose format
       	$privs = $inst_info_list{$key}[2];
       	$privs =~ s/assignments/Manage assignments/;
       	$privs =~ s/students/Manage students/;
       	print qq|<DT><b>$key</b>\n|;
       	print qq|<DD>$inst_info_list{$key}[0]<DD>$privs\n|;
    }

    print qq|</DL><CENTER><H2>$GLOBALS::HR<BR>Students</H2></CENTER><DL>|;
    foreach $key (sort (keys %stud_info_list)) {
       	print qq|<DT><b>$key</b>\n|;
       	print qq|<DD>$stud_info_list{$key}[0]\n|;
    }
    print qq|</DL><CENTER>$GLOBALS::HR</CENTER><br>|;
}

1;
