# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub write_test {
   my ($self, $status) = @_;
   my (%answers, @questions, $cn_q, $num_questions, $assign_str, $fname);

   if ($status eq 'ungraded') { 
       $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
       $dt = CN_UTILS::getTime($fname);
   } 
   else {
       $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
       $dt = $self->{'Test Header'}{'SEEN'};
   }

   # Open file
   open(ASSIGN, ">$fname") or
       &ERROR::system_error("TEST","write_test","open",$fname); 
   flock(ASSIGN, $LOCK_EX);
   $type = ref($self);
   if (!defined $dt) {
       $dt = CN_UTILS::getTime($fname);
   }
   $dt = "SEEN=\"$dt\"";
   my $subdt = $self->{'Test Header'}{'SUBDATE'};
   if (!defined $subdt || $status eq 'ungraded') {
       $subdt = CN_UTILS::currentTime();
   }
   $subdt = "SUBDATE=\"$subdt\"";
   my $ungrade = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   if ($status eq 'partial' && (-e $ungrade)) {
     $submit = 2;
   } else {
     $submit = 1;
   }
   print ASSIGN "<CN_ASSIGN TYPE=$type SUBMIT=$submit $dt $subdt PTS=\"$self->{'Test Header'}{'PR'}/$self->{'Test Header'}{'TP'}\">\n";
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});   

   my $stud_ans = $self->{'Stud Answers'};
   foreach $q_name (@q_names) {
       my $pp = $stud_ans->{$q_name}{'PP'};
       my $tp = $stud_ans->{$q_name}{'TP'};
       my $pr = $stud_ans->{$q_name}{'PR'};
       print ASSIGN "<CN_Q NAME=\"$q_name\" PTS=$pp/$tp PR=$pr>\n$stud_ans->{$q_name}{'ANS'}\n";
   }

   flock(ASSIGN, $LOCK_UN);
   close(ASSIGN);
   chmod 0600, $fname;
   # If we wrote a graded test, make sure the ungraded file is removed
   ($status eq 'graded' || $status eq 'partial') and unlink $ungrade;
}

1;
