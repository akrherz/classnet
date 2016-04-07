# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub read_all {
   my $self = shift;
   my ($q_name,@q_names,$stud_ans);
   my %bl_q;
   my ($nb, $nq, $b);

   $nb = $self->block_count();
   for ($b = 1; $b <= $nb; $b++) {
       # Read in block header <CN_BLOCK...>
       %params = $self->read_block($b);
       $bl_q{$b} = {%params};
       $nq = $self->question_count($b);
       for ($q = 1; $q <= $nq; $q++) {
       	   # Read in question header <CN_Q ...>
       	   %params = $self->read_question($b,$q);
       	   $bl_q{"$b.$q"} = {%params};
       }
   }

   $self->{'bl_q'} = \%bl_q;
}

1;
