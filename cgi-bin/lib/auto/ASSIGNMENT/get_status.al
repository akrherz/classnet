# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub get_status {

   my $self = shift;

   my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}"; 
   if (-e $fname) {
       return 'graded';
   }
   
   $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}"; 
   if (-e $fname) {
       # check to see if it is an old unsubmitted assignment
       #$/ = "\n";
       #open(ASN,"<$fname");
       #my $header = <ASN>;
       #close ASN;
       #if ($header =~ / SUBMIT=0/) {
       #    $self->{'SEEN'} = CN_UTILS::getTime($fname);
       #    if (-M _ > 1) {
       #        unlink $fname;
       #        return 0;
       #    }
       #}
       return 'ungraded';
   }
   return 0;

}

1;
