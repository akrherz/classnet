# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub get_graded_form {
   my $self = shift;
   my ($q_name,@q_names,$stud_ans);

   # First try to grade if ungraded
   ($self->get_status() eq 'ungraded') and
       $self->grade();
   ($self->get_status() ne 'graded') and
       ERROR::user_error($ERROR::UNGRADED);

   # May the test be viewed?
   %assign_params = $self->read();
   ($assign_params{'VIEW'} == 0) and
       ERROR::user_error($ERROR::ASNNOVIEW, $self->{'Name'});

   # Read the test
   $self->read_test();

   # Read all blocks and questions
   !($self->{'bl_q'}) and
       $self->read_all();
   my $bl_q = $self->{'bl_q'};
   
   # Construct the form
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   $stud_ans = $self->{'Stud Answers'};

   $,="<br>  \n";
   # Start the form
   $form = "<FORM>\n";
   my %values = $self->get_runtime_values();
   my $qcnt = 0;
   while (@q_names) {
       my $q_name = shift @q_names;
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my $root = "$b_num.$q_num";
       $form .= $self->check_java("$bl_q->{$b_num}{'btext'}","play");
       my $ans = $stud_ans->{$q_name}{'ANS'};
       $pr = $stud_ans->{$root}{'PR'};
       $tp = $stud_ans->{$root}{'TP'};
       my $key_ans = $bl_q->{$root}{'ANS'};
       if (defined %values) {
           $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
       }
       # replace remaining dynamic values with N/A
       $key_ans =~ s/{\s*(\w+)\s*}/Not Available/g;
       my $feedback = $bl_q->{$root}{'feedback'};
       my $q_type = $bl_q->{$root}{'Question Type'};
       # Check for multiple blanks
       if ($q_type eq 'BLANK') {
           my @ans_array = ();
           $ans_array[$blank_num-1] = $ans;
       	   $q_name = shift @q_names;
       	   while ($q_name =~  m/^$root\.(\d+)/) {
       	       $ans_array[$1-1] = ($q_type eq 'MULTIPLE')?
                           "$1":$stud_ans->{$q_name}{'ANS'};
       	       $q_name = shift @q_names;
       	   }
           $ans = join("%2C",@ans_array);
       	   (defined $q_name) and unshift(@q_names, $q_name);
           $pr = $stud_ans->{"$root.1"}{'PR'};
           $tp = $stud_ans->{"$root.1"}{'TP'};
       } elsif ($q_type eq 'MULTIPLE') {
           $ans = '';
           $i = 0;
       	   while ($q_name =~  m/^$root\.(\d+)/) {
       	       if ($stud_ans->{$q_name}{'ANS'} == 1) {
                   $ans .= ($ans eq '')?$1:"%2C$1";
               }
       	       $q_name = shift @q_names;
               $i++;
       	   }
	   if ($i == 0) {
               ERROR::user_error($ERROR::NOTDONE,"show the assignment since the
instructor has changed the questions");
           }
       	   (defined $q_name) and unshift(@q_names, $q_name);
           $pr = $stud_ans->{"$root.1"}{'PR'};
           $tp = $stud_ans->{"$root.1"}{'TP'};
       }
       $question = $self->replace_placeholders($ans, $b_num, $q_num, %{$bl_q->{$root}});
       if ($q_type =~ /CHOICE/) {
       	   $key_ans = "$key_ans";
       } elsif ($q_type =~ /LIKERT/) {
           $key_ans = 'N/A';
       } elsif ($q_type =~ /ESSAY/) {
       	   # There are a bunch of ways to do this. Just use another
       	   # textarea box for now
       	   $key_ans = $self->replace_placeholders($key_ans, $b_num, $q_num, %{$bl_q->{$root}});
       	   $key_ans =~ s/.*(<TEXTAREA.*\/TEXTAREA>).*/<br>$1/si;
       }
       ($feedback) and
       	   $feedback = ($feedback =~ /\S/mi) ? "<br>Feedback:$feedback" : "";
       $qcnt++;
       $form =
"$form$qcnt) $question<br><B>Answer:</B> $key_ans<br><B>Points:</b> $pr of $tp<br>$feedback<HR>";
   }   
   # Finish the form
   $form = "$form</FORM><CENTER><B>Total Score:</B> $self->{'Test Header'}{'PR'} of $self->{'Test Header'}{'TP'}</CENTER><P>";
   return $form;
}

1;
