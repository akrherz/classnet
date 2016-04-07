# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub source {
    my ($self) = @_;
    my $src = ASSIGNMENT::source($self);
   my $b;
   my $nb = $self->block_count();
   for ($b = 1; $b <= $nb; $b++) {
       # Read in block header <CN_BLOCK...>
       %params = $self->read_block($b,1);
       chomp ($params{'cn_block'});
       my $txt = CN_UTILS::remove_spaces($params{'btext'});
       $src .= "$params{'cn_block'}\n$txt\n";
       $nq = $self->question_count($b);
       for ($q = 1; $q <= $nq; $q++) {
       	   # Read in question header <CN_Q ...>
       	   %params = $self->read_question($b,$q,1);
       	   chomp ($params{'cn_q'});
           my $txt = CN_UTILS::remove_spaces($params{'qtext'});
           $src .= "$params{'cn_q'}\n$txt\n";
           my $txt = CN_UTILS::remove_spaces($params{'feedback'});
           $src .= "<CN_FEEDBACK>\n$txt\n";
       }
       $src .=  "</CN_BLOCK>\n";
   }
   return $src;
}

1;
