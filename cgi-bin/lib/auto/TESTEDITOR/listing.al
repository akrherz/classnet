# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

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
       ASSIGNMENT->print_menu($cls,$asn->{'Member'});
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

1;
