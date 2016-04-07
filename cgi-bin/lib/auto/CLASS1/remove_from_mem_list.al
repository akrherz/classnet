# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub remove_from_mem_list {
   my ($self, $mem_type, $mem_name) = @_;
   my $i;

   my $fname = "$self->{'Root Dir'}/admin/member_lists/${mem_type}s";
   # Get list of members
   open(MEM_LIST, "<$fname");
   my @mem_list = <MEM_LIST>;
   chomp @mem_list;

   for ($i = 0; ( ($i < @mem_list) and ($mem_name ne $mem_list[$i]) ); $i++) {}
   splice(@mem_list,$i,1);   
       	   
   open(MEM_LIST, ">$fname") or 
       	   &ERROR::system_error("CLASS","remove_from_mem_list","Open",$mem_type);
   $, = "\n";
   flock(MEM_LIST,$LOCK_EX);
   print MEM_LIST @mem_list;
   flock(MEM_LIST,$LOCK_UN);
   close(MEM_LIST);
   chmod 0700, $fname;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   unlink $fname;
}

1;
