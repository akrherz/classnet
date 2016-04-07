# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub get_ungraded_form {
   my $self = shift;
   my ($q_name,@q_names,$stud_ans);

   # Read the test
   $self->read_test();

   # Construct the form
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   $stud_ans = $self->{'Stud Answers'};
   # Start the form

   $form =<<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/assignments">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit TEST">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Member'}->{'Ticket'}">
FORM

   while (@q_names) {
       my $q_name = shift @q_names;
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my %b_params = $self->read_block($b_num);
       $form .= $self->check_java($b_params{'btext'},"record");
       my %q_params = $self->read_question($b_num,$q_num);
       my $ans = $stud_ans->{$q_name}{'ANS'};
       if ($q_params{'Question Type'} eq 'BLANK') {
       # Check for multiple blanks
           if (defined $blank_num) {
               my $root_name = "$b_num.$q_num";
               my @ans_array = ();
               $ans_array[$blank_num-1] = $ans;
       	       $q_name = shift @q_names;
       	       while ($q_name =~  m/^$root_name.(\d+)/) {
       	           $ans_array[$1-1] = $stud_ans->{$q_name}{'ANS'};
       	           $q_name = shift @q_names;
       	       }
               $ans = join("%2C",@ans_array);
       	       (defined $q_name) and unshift(@q_names, $q_name);
           }
       } elsif ($q_params{'Question Type'} eq 'MULTIPLE') {
           $form = "$form\n<INPUT TYPE=hidden NAME=$b_num. VALUE=MULTIPLE>\n";
           $ans = '';
           my $root_name = "$b_num.$q_num";
      	   while ($q_name =~  m/^$root_name.(\d+)/) {
       	       if ($stud_ans->{$q_name}{'ANS'} eq '1') {
                   $ans .= ($ans eq '')?$1:"%2C$1";
               }
       	       $q_name = shift @q_names;
       	   }
       	   (defined $q_name) and unshift(@q_names, $q_name);
       }
       $question = $self->replace_placeholders($ans, $b_num, $q_num, %q_params);
       $form = "$form<B>$b_num)</B> $question<HR>";

   }   
   # Finish the form
   $form = "$form<CENTER><H4><INPUT TYPE=submit VALUE=Submit>
       	   <INPUT TYPE=reset></H4><p></CENTER>\n</FORM>";

   return $form;

}

1;
