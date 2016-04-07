# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

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

1;
