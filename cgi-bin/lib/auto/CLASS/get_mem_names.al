# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub get_mem_names {
   my ($self, $mem_type) = @_;
   my @mem_names;

   if ($mem_type eq 'requests') {
       opendir(MEM_LIST,"$self->{'Root Dir'}/admin/members/requests") or
       	   ERROR::system_error("CLASS", "get_cls_mem_info",
                               "opendir $mem_type",$self->{'Root Dir'});
       @mem_names = grep (!/^\./,readdir(MEM_LIST));
       closedir(MEM_LIST);
       foreach $member (@mem_names) {
       	   $member = CGI::unescape($member);
       }
   } else {
       $/ = "\n";
       open(MEM_LIST, "<$self->{'Root Dir'}/admin/member_lists/${mem_type}s");
       chomp (@mem_names = <MEM_LIST>);
       close(MEM_LIST);
   }
   return @mem_names;
}

1;
