# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub send_edit_form {
   my ($self,$query,$stu) = @_;
   my ($q_name,@q_names,$stud_ans);

   my $nstu = @{$stu};
   if ($nstu != 1) {
      ERROR::print_error_header('Edit?');
      print "Please select only one student.";
      CN_UTILS::print_cn_footer();
      exit(0);
   }
   ($self->get_status() eq 'ungraded') and
       $self->grade();
   my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}"; 
   (-e $fname) or
       ERROR::user_error($ERROR::UNGRADED,
       "$self->{'Member'}->{'Username'} has possibly not turned in
$self->{'Name'} or Classnet is waiting for a due date to pass");

   # Read the test
   $self->read_test();

   # Read all blocks and questions
   !($self->{'bl_q'}) and
       $self->read_all();
   my $bl_q = $self->{'bl_q'};
   
   # Start the form
   $form =<<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/gradebook">
<INPUT TYPE=hidden NAME=cn_option VALUE="Submit Edit Changes">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$query->{'Ticket'}->[0]">
<INPUT TYPE=hidden NAME="Student File" VALUE="$self->{'Student File'}">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
FORM
   # Construct the form
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   $stud_ans = $self->{'Stud Answers'};
   my %values = $self->get_runtime_values();
   while (@q_names) {
       my $q_name = shift @q_names;
       my ($b_num,$q_num,$blank_num) = split(/\./,$q_name);
       my $root = "$b_num.$q_num";
       $form .= $self->check_java("$bl_q->{$b_num}{'btext'}","play");
       my $ans = $stud_ans->{$q_name}{'ANS'};
       my $pts = "<B>Points:</B> <INPUT NAME=\"$b_num.$q_num PR\" SIZE=3 VALUE=\"$stud_ans->{$q_name}{'PR'}\"> of $stud_ans->{$q_name}{'TP'}";
       my $key_ans = $bl_q->{$root}{'ANS'};
       (%values) and $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
       $key_ans =~ s/{\s*(\w+)\s*}/Not Available/g;
       my $q_type = $bl_q->{$root}{'Question Type'};
       if ($q_type eq 'LIKERT') {
           $key_ans = 'N/A';
       } elsif ($q_type eq 'BLANK') {
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
       } elsif ($q_type =~ /ESSAY/) {
       	   #$key_ans = "";
       }
       $question = $self->replace_placeholders($ans, $b_num, $q_num, %{$bl_q->{$root}});
       $form = "$form<B>$b_num)</B> $question<P><B>Answer:</B> $key_ans<br>$pts</b><br>$feedback<HR>";
   }   

   # Finish the form
   $self->print_base_header();
   print "<B>Student:</B> $self->{'Member'}->{'Username'}<BR><B>Current Score:</B> $self->{'Test Header'}{'PR'} of $self->{'Test Header'}{'TP'}$GLOBALS::HR";
   print "$form<H4><CENTER><INPUT TYPE=submit VALUE=\"Submit Changes\"></CENTER></H4></FORM>";
   CN_UTILS::print_cn_footer();
   exit(0);
}

1;
