# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub get_member {
   my ($self, $query, $uname) = @_;
   my $mem,$tkt;

   # Change Username to disk representation;

   if (!(defined $uname)) {
       # get the ticket filename from the query
       $tkt = $query->param('Ticket');
       my $ticketfile = "$GLOBALS::TICKET_DIR/$tkt";
       if (-e $ticketfile) {
           (open(TICKET_FILE, "<$ticketfile")) or
         	   &ERROR::system_error("CLASS","get_member","Open",$ticketfile);
           @line = <TICKET_FILE>;
           close(TICKET_FILE);
           chomp(@line);
           $uname = $line[0];
       } else {
       	   ERROR::user_error($ERROR::NOTICKET);
       }
   }
   $query->{'Username'}->[0] = $uname;
   my $disk_uname = CN_UTILS::get_disk_name($uname);
   my $mem_type = $self->mem_exists($disk_uname);

   if ($mem_type eq 'instructor') {
       $mem = INSTRUCTOR->new($query, $self, $uname); 
   }
   elsif ($mem_type eq 'student') {
       $mem = STUDENT->new($query, $self, $uname);
       # Is a student attempting an instructor option?
       if ( (defined $query->{'cn_option'}->[0]) and 
		(index("inst",$query->{'cn_option'}->[0]) == 0)) {
       	       ERROR::user_error($ERROR::NOPERM);
       }
   }
   elsif ($mem_type eq 'requests') {
       ERROR::user_error($ERROR::ENROLL);
   }
   else {
       ERROR::user_error($ERROR::MEMBERNF,$uname);
   }

   $mem->{'Member Type'} = $mem_type;
   $mem->{'Ticket'} = $tkt;
   return $mem;  

}

1;
