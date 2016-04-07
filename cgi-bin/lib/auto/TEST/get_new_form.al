# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub get_new_form {
   my ($self,$memtype,$submit) = @_;
   my (@blocks, $form, @questions, $question_num, $question, $vers_num);
   my (@names, %q_params, %b_params, %assign_params, $num_questions);
   my $rand_length = (length($self->{'Member'}->{'Last Name'}))**3;
   my $vers_num = 0;
   my $tot_pts = 0;

   # Make a key if it doesn't exist and this isn't instructor
   $self->make_key() unless ($memtype eq 'instructor');

   # Get assignment options(?) and block numbers
   if (!$self->{'Key Header'})  {
       %assign_params = $self->read();
       (defined %assign_params) or
            ERROR::system_error('TEST','get_new_form','read header',
                            "$self->{'Dev Root'}/options");
       $self->{'Key Header'} = \%assign_params;
   }

   # Set random seed and version number
   srand (time ^ $$ ^ $rand_length);
   ($assign_params{'OPT'} =~ m/VERS=(\d+)/i) and $vers_num = int(rand($1)) + 1;

   # Start the form
   if (!(defined $inst)) {
   $form =<<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/assignments">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit TEST">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Member'}->{'Ticket'}">
FORM
   }
   else {
       $form = "<FORM>";
   }

   my $num_blocks = $self->block_count();
   my $block;
   for ($block=1; $block<=$num_blocks; $block++) {

       # Read the current block and add any html to the form
       %b_params = $self->read_block($block);
       # $form .= $self->check_java($b_params{'btext'},"record");
       if ($memtype eq 'student') {
           $form .= $self->check_java($b_params{'btext'},"record");
       }
       else {
           $form .= $self->check_java($b_params{'btext'},"demo");
       }
       
       # Get number of questions
       $num_questions = $self->question_count($block);

       # Which question number to use?
       if (!$vers_num) {
       	   $question_num = int(rand($num_questions)) + 1;
       }
       elsif ($vers_num > $num_questions) {
       	   $question_num = $num_questions;
       }
       else {
       	   $question_num = $vers_num;
       }

       %q_params = $self->read_question($block,$question_num);
       $question = $self->replace_placeholders("",$block, $question_num, %q_params);

       # Save the name of the question and set pts;
       $tot_pts += $b_params{'TP'};
       if ($q_params{'Question Type'} =~ /BLANK/i) {
           # Multiple blanks may appear in one question.
       	   my $n = $q_params{'N'};
       	   ($n == 0) and
              ERROR::user_msg("A fill in the blank question has no blank.");
       	   my $tot_pts = $b_params{'TP'};
       	   my $part_pts = $b_params{'PP'};
       	   for ($i=1; $i<=$n; $i++) {
       	       push (@names, "<CN_Q NAME=\"$block.$question_num.$i\" PTS=$part_pts/$tot_pts PR=0>\n\n");
       	   }
       } elsif ($q_params{'Question Type'} =~ /MULTIPLE/i) {
           #Total and Partial pts are divided by number of correct answers
       	   my $n = $q_params{'N'};
       	   ($n == 0) and
       	       ERROR::user_msg("A MULTIPLE question has no choices.");
       	   my $tot_pts = $b_params{'TP'};
       	   my $part_pts = $b_params{'PP'};
           #Note in form that this question is MULTIPLE
           $form = "$form\n<INPUT TYPE=hidden NAME=$block. VALUE=MULTIPLE>\n";
       	   for ($i=1; $i<=$n; $i++) {
       	       push (@names, "<CN_Q NAME=\"$block.$question_num.$i\" PTS=$part_pts/$tot_pts PR=0>\n\n");
           }
       } else {
       	   push (@names, "<CN_Q NAME=\"$block.$question_num\" PTS=$b_params{'PP'}/$b_params{'TP'} PR=0>\n\n");
       }
       $form = "$form<B>$block) </B> $question<HR>";
   }

   # Finish the form

   # If instructor just return the form
   if ($memtype eq 'instructor') {
       $form = "$form</FORM>";
       return $form;
   }

   $form = "$form<CENTER><H4><INPUT TYPE=submit Value=Submit>
       	   <INPUT TYPE=reset></H4><p></CENTER>\n</FORM>";

   # Store the question names
   my $file = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   open(STUD_ANS,">$file") or
       ERROR::system_error('TEST.pm',"get_form_string","open",$file);
   my $type = ref($self);
   my $sval = ($submit eq 'submit')? 1 : 0;
   print STUD_ANS "<CN_ASSIGN TYPE=$type SUBMIT=$sval PTS=\"0/$tot_pts\">\n", @names;
   close STUD_ANS;
   chmod 0600, $file;

   return $form;

}

1;
