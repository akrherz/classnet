# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub read_test {
   my ($self) = @_;
   my (%answers, @questions, $cn_q, $num_questions, $assign_str, $fname);
   my ($name, %q_info);

   $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
   if (!(-e $fname)) {
       $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   }
   if (!(-e $fname)) {
       return 0;
   }
   # Get questions
   open(ASSIGN, "<$fname") or
       ERROR::system_error("TEST","read_test","open","$fname"); 
   flock(ASSIGN, $LOCK_EX);
   undef $/;
   $assign_str = <ASSIGN>;
   flock(ASSIGN, $LOCK_UN);
   close(ASSIGN);
   
   $/="";
   @questions = split(/(<CN_Q.*>)/,$assign_str);
   chomp @questions;

   # Get the header
   my $test_header = shift @questions;
   my %test_params = TEST::unpack_stud_test_header($test_header);
   (%test_params) or
        ERROR::system_error('TEST','read_test','unpack stheader',
                            "$fname:$test_header");
   $self->{'Test Header'} = \%test_params;
   
   # Read in the question answers
   my $num_questions = grep(/<CN_Q/, @questions);
   for ($q_num=1; $q_num<=$num_questions; $q_num++) {
       $cn_q = shift @questions;
       %q_info = TEST::unpack_stud_question_header($cn_q);
       (%q_info) or
            ERROR::system_error('TEST','read_test','unpack qheader',
                                "$fname:$cn_q");
       $q_info{'ANS'} = shift @questions;
       # Remove beginning and ending whitespace
       $q_info{'ANS'} = CN_UTILS::remove_spaces($q_info{'ANS'});
       $name = $q_info{'NAME'};
       undef $q_info{'NAME'};
       $answers{$name} = { %q_info };
   }
   $self->{'Stud Answers'} = \%answers;
   return 1;
}

1;
