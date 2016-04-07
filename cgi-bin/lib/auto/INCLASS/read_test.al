# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub read_test {
   my ($self) = @_;
   my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
   if ($self->get_status() eq 'graded') {
       $/ = "\n";
       open(ASSIGN, "<$fname") or
           ERROR::system_error("INCLASS","read_test","open",$fname); 
       flock(ASSIGN, $LOCK_EX);
       $header = <ASSIGN>;
       flock(ASSIGN, $LOCK_UN);
       close(ASSIGN);
       (($header =~ m/\sPTS="([^"]*)/i) or ($header =~m/\sPTS=(\S*)/i)) and
           $tp = $1;
       (($header =~ m/\sPR="([^"]*)/i) or ($header =~m/\sPR=(\S*)/i)) and
           $pr = $1;
   } else {
       my %params = $self->read();
       $tp = $params{'TP'};
       $pr = 0;
   }
   $self->{'TP'} = $tp;
   $self->{'PR'} = $pr;
}

1;
