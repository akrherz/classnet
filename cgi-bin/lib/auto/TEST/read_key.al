# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub read_key {

   my $self = shift;
   my (@cn_blocks, $key_str,  @questions, %questions, $header, @header_block, %q_info, %b_info);
   my (%grade_info, $cn_block, $cn_q, $block_name, $num_questions, %assign_params);

   # Get the test header

   %assign_params = $self->read();
   (defined %assign_params) or
        ERROR::system_error('TEST','read_key','read header',
                            "$self->{'Dev Root'}/options");
   $self->{'Key Header'} = \%assign_params;
   
   # Make the key if necessary
   $self->make_key();

   # Read key into single string
   open(KEY, "<$self->{'Key Path'}") or
       &ERROR::system_error('TEST',"read_key","open","$self->{'Key Path'}");
   flock(KEY, $LOCK_EX);
   undef $/;
   $key_str = <KEY>;
   flock(KEY, $LOCK_UN);
   close(KEY);

   # Get rid of any ending newlines
   $/="";
   chomp $key_str;

   # Get question blocks from key
   @cn_blocks = split(/\n<\/CN_BLOCK>\n?/,$key_str);

    # Fill in question names, answers and grading data
   for ($block_num=0; $block_num<@cn_blocks; $block_num++) {
       # Get cn_block string       
       @questions = split(/(<CN_Q.*>)/,$cn_blocks[$block_num]);
       chomp @questions;
       $cn_block = shift @questions;

       # Get Pts out of the block
       %b_info = TEST::unpack_block_header($cn_block);
       (defined %b_info) or
           ERROR::system_error('TEST','read_key','unpack_block_header',
                               "$fname:$cn_block");
       # Parse the cn_q's
       $num_questions = grep(/<CN_Q/, @questions);
       for ($q_num=1; $q_num<=$num_questions; $q_num++) {
       	   $cn_q = shift @questions;

       	   # Get question parameters
       	   %q_info = TEST::unpack_question_header($cn_q);
           (defined %q_info) or
               ERROR::system_error('TEST','read_key','unpack_question_header',
                                   "$fname:$cn_q");
       	   $q_info{'TP'} = $b_info{'TP'};
       	   $q_info{'PP'} = $b_info{'PP'};

       	   # Any feedback follows the cn_q
       	   $feedback = "";
       	   (@questions and !($questions[0] =~ /<CN_.*>/)) and 
       	       $q_info{'Feedback'} = shift @questions; 

       	   # Get block name
       	   $block_name = $block_num+1;

           $questions{"$block_name.$q_num"} = { %q_info };

       	   # Store array and check for multiples and blanks
       	   # All Blanks and Multiples are named with 3 sets of digits
           if ($q_info{'Question Type'} =~ m/BLANK/i) {
               my $n = @q_info{'N'};
       	       my @answers = split(/,/, $q_info{'ANS'});
       	       grep {s/%22/"/g; s/%2C/,/g} @answers;
       	       for ($i = 1; $i <= $n; $i++) {
       	       	   $questions{"$block_name.$q_num.$i"} = { %q_info };
       	       	   $questions{"$block_name.$q_num.$i"}{'ANS'} = $answers[$i-1];
       	       }
       	   } elsif ($q_info{'Question Type'} =~ m/MULTIPLE/i) {
               my $n = $q_info{'N'};
       	       my $ans = $q_info{'ANS'};
       	       for($i = 1; $i <= $n; $i++) {
       	       	   $questions{"$block_name.$q_num.$i"} = { %q_info };
       	       	   $questions{"$block_name.$q_num.$i"}{'ANS'} = 
                       (($ans =~ /$i/)?$i:0); 
       	       }
       	   }
       }
   }
   # Store reference to %questions
   $self->{'Key'} = \%questions;

}

1;
