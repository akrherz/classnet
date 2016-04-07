# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub add_to_mem_list {
   my ($self, $mem_type, @name_list) = @_;

   my $fname = "$self->{'Root Dir'}/admin/member_lists/${mem_type}s";
   # Add class to classlist file
   open(MEM_LIST, "<$fname");
   my @mem_names = <MEM_LIST>;
   push (@mem_names, @name_list);
   open(MEM_LIST, ">$fname") or 
       	   &ERROR::system_error("CLASS","add_to_mem_list","Open list",$mem_type);
   flock(MEM_LIST,$LOCK_EX);
   chomp (@mem_names = sort @mem_names);
   $, = "\n";
   print MEM_LIST @mem_names;
   flock(MEM_LIST,$LOCK_UN);
   close(MEM_LIST);
   chmod 0700, $fname;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   unlink $fname;
}

1;
