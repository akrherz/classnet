# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub write_test {
   my ($self, $status) = @_;
   if ($status eq 'graded') { 
       $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
   } 
   else {
       $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}";
   }

   # Open file
   open(ASSIGN, ">$fname") or
       ERROR::system_error("INCLASS","write_test","open",$fname); 
   flock(ASSIGN, $LOCK_EX);
   $type = ref($self);
   print ASSIGN "<CN_ASSIGN TYPE=$type SUBMIT=1 PTS=$self->{'TP'} PR=$self->{'PR'} >\n";
   flock(ASSIGN, $LOCK_UN);
   close(ASSIGN);
   chmod 0600, $fname;
   # If we wrote a graded test, make sure the ungraded file is removed
   ($status eq 'graded') and unlink "$self->{'Ungraded Dir'}/$self->{'Student File'}";
}

1;
