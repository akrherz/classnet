# NOTE: Derived from lib/EVAL.pm.  Changes made here will be lost.
package EVAL;

sub mail_raw_data {
    my ($self,$stud_names) = @_;
    my $cls = $self->{'Class'};
    my @snames = $cls->get_mem_names('student');
    my @snames1 = @{$stud_names};
    my $n = @snames;
    my $n1 = @snames1;
    if ($n != $n1) {
        ERROR::print_error_header('Data for Evaluation');
        print "You may only print evaluation data for ALL students.";
        CN_UTILS::print_cn_footer();
        exit(0);
    }
    # Randomize the student names
    my @rand_array;
    push(@rand_array,splice(@snames1,rand(@snames1),1))
        while @snames1;
    ASSIGNMENT->mail_raw_data($self,\@rand_array);
}

1;
