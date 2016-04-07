# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub get_mem_info {
   my ($self,$uname) = @_;
   my %pairs;

   my $disk_uname = CN_UTILS::get_disk_name($uname);
   my $mem_type = $self->mem_exists($disk_uname);
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$disk_uname";
   open(MEM_FILE, "<$fname") or
       ERROR::user_error($ERROR::MEMBERNF,$uname);

#   flock($fname, LOCK_EX);
   chop($pair{'Member Type'} = $mem_type);
   while (<MEM_FILE>) {
       chop;
       my ($name,$value) = split(/=/);
       $pairs{$name} = $value;
   }
   ($pairs{'Last Name'}, $pairs{'First Name'}) = split(/, /,$uname);
   return %pairs;
}

1;
