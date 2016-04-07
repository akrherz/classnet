# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub grade {
   my ($self) = @_;

   # no need to grade if not published
   if ($self->{'Dev Root'} =~ /.develop/) {
       return;
   }

   # Do we have the key header?
   if (!$self->{'Key Header'})  {
       my %assign_params = $self->read();
       (defined %assign_params) or
            ERROR::system_error('TEST','grade','read header',
                                "$self->{'Dev Root'}/options");
       $self->{'Key Header'} = \%assign_params;
   }

   # Only grade if after the due date
   (!$self->due_date_past() and (defined $self->{'Key Header'}{'DUE'}))  and 
       return;

   # Has key been read or constructed?
   $self->{'Key'} or $self->read_key();

   # Read the ungraded assignment
   if ($self->read_test() == 0) {
       return;
   }

   # Has at least one submission occurred?
   if ($self->{'Test Header'}{'SUBMIT'} == 0) {
       return;
   }

   # Perform the grading
   my @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   my $key = $self->{'Key'};
   my $stud_ans = $self->{'Stud Answers'};
   my $pts_rec = 0;
   my $q_status = "graded";
   while (@q_names) {
       my $q_name = shift(@q_names);
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my @q_list = ();
       if (defined $blank_num) {
           $root = "$b_num.$q_num";
           $n = $key->{$root}{'N'};
           $ans = $key->{$root}{'ANS'};
           if ($key->{$root}{'Question Type'} =~ /BLANK/i) {
               $correct = 1;
       	       # answers were already split in read_key
               # @answers = split(/%2C/,$ans);
               for ($i = 1; $i <= $n; $i++) {
                   if ($correct and !$self->match($key->{"$root.$i"}{'ANS'},
                                    $stud_ans->{"$root.$i"}{'ANS'},
                                    $key->{$root}{'JUDGE'})) {
                       $correct = 0;
                   }
                   #NOTE: This list sequence will likely not match for loop sequence
                   push(@q_list,$q_name);
                   $q_name = shift(@q_names);
               }

               (defined $q_name) and unshift(@q_names,$q_name);
               $q_name = "$root.1";
           } elsif ($key->{$q_name}{'Question Type'} =~ /MULTIPLE/i) {
               $correct = 1;
               my %values = $self->get_runtime_values();
               (defined %values) and $ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
               $ans =~ s/{\s*(\w+)\s*}//g;
               $ans = CN_UTILS::remove_spaces($ans);
               @answers = split(/,/,$ans);
               for ($i = 1; $i <= $n; $i++) {
                   my $is_ans = 0;
                   if ($ans ne '') {
                       foreach $a (@answers) {
                           if ($a == $i) {
                               $is_ans = 1; last;
                           }
                       }
                       if (($is_ans and !$stud_ans->{"$root.$i"}{'ANS'}) or
                           (!$is_ans and $stud_ans->{"$root.$i"}{'ANS'})){
                           $correct = 0;
                       }
                   }
                   push(@q_list,$q_name);
                   $q_name = shift(@q_names);
               }
               (defined $q_name) and unshift(@q_names,$q_name);
               $q_name = "$root.1";
          };
       } else {
           if (!($key->{$q_name}{'Question Type'} =~ /LIKERT/i)) {
               $correct = $self->match($key->{$q_name}{'ANS'}, 
                                       $stud_ans->{$q_name}{'ANS'},
                                       $key->{$q_name}{'JUDGE'});
           }
           push(@q_list,$q_name);
       }
       if ($key->{$q_name}{'Question Type'} =~ /ESSAY/i) {
           $q_status = "partial";
           $pts = $stud_ans->{$q_name}{'PR'};
           push(@q_list,$q_name);
       } elsif ($key->{$q_name}{'Question Type'} =~ /LIKERT/i) {
           $ans = $key->{$q_name}{'ANS'};
           my %values = $self->get_runtime_values();
           (defined %values) and $ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
           $ans =~ s/{\s*(\w+)\s*}//g;
           $sans = $stud_ans->{$q_name}{'ANS'};
           if ($ans eq '') {
               $pts = $sans;
           } else {
               my @wts = split(/,/,$ans);
               $pts = ($sans <= $#wts) ? $wts[$sans-1]:$wts[$#wts];
           }
           push(@q_list,$q_name);
       } else {
           $pts = $correct? $key->{$q_name}{'TP'}: 
                            $key->{$q_name}{'PP'};
       }
       $pts_rec += $pts;
       foreach $qn (@q_list) {
           $stud_ans->{$qn}{'TP'} = $key->{$qn}{'TP'};
           $stud_ans->{$qn}{'PP'} = $key->{$qn}{'PP'};
           $stud_ans->{$qn}{'PR'} = $pts;
       }
   }
   # Set points received and store the graded assignment

   $self->{'Test Header'}{'PR'} = $pts_rec;
   $self->{'Test Header'}{'TP'} = $self->{'Key Header'}{'TP'};
   $self->write_test($q_status);
}

1;
