# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub make_key {
   my ($self) = @_;
   my (%params,$b,$nb);
   my $tot_pts = 0;

   # Remove all trailing newlines on chomp
   $/="";

   if (-e $self->{'Key Path'}) {
       return;
   }
   open(KEY,">$self->{'Key Path'}") or
        &ERROR::system_error('TEST','make_key','open',"$self->{'Key Path'}");
   flock(KEY, LOCK_EX);
   $nb = $self->block_count();
   for ($b = 1; $b <= $nb; $b++) {
       # Read in block header <CN_BLOCK...>
       %params = $self->read_block($b,1);
       chomp ($params{'cn_block'});
       # Add to total pts
       if ($params{'cn_block'} =~ m/\sPTS="?([+|-]?[.|\d]+)\/([+|-]*[.|\d]+)/ ) {
       	   $tot_pts += $2;
       }
       elsif ($params{'cn_block'} =~ m/\sPTS="?([+|-]?[.|\d]+)/)  {
       	   $tot_pts += $1;
       }
       else {
       	   $tot_pts += 1;
       }

       $params{'cn_block'} =~ m/<CN_BLOCK.*TP="?(\d+)/i;
       print KEY "$params{'cn_block'}\n";
       $nq = $self->question_count($b);
       for ($q = 1; $q <= $nq; $q++) {
       	   # Read in question header <CN_Q ...>
       	   %params = $self->read_question($b,$q,1);
       	   chomp ($params{'cn_q'});
       	   print KEY "$params{'cn_q'}\n";
       	   if ($params{'feedback'}) {
       	       chomp ($params{'feedback'});
       	       print KEY "$params{'feedback'}\n";
       	   }
       }
       print KEY "</CN_BLOCK>\n";
   }
   flock(KEY, $LOCK_UN);
   close KEY;
   chmod 0600, "$self->{'Key Path'}";

   # Add Total pts to options file
   my %params = $self->read();
   (%params) or
        ERROR::system_error('TEST','make_key','read header',
                            "$self->{'Dev Root'}/options");
   $params{'TP'} = $tot_pts;
   $self->write(%params);

}

1;
