# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub get_email_addr {
   my ($self,$uname) = @_;

   my $disk_uname = CN_UTILS::get_disk_name($uname);
   my $mem_type = $self->mem_exists($disk_uname);
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$disk_uname";
   open(MEM_FILE, "<$fname") or
       ERROR::user_error($ERROR::MEMBERNF,$uname);
   while (<MEM_FILE>) {
       chop;
       my ($name,$value) = split(/=/);
       if ($name eq 'Email Address') {
           return $value;
       }
   }
   return '';
}

1;
