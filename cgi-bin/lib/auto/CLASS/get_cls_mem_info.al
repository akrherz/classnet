# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub get_cls_mem_info {
   my ($self, $mem_type) = @_;
   my (@members, %mem_info_list);

   @members = $self->get_mem_names($mem_type);

   return "" unless @members;

   # Create a hash of lists
   #  $mem_info_list{last_name, first_name} => [email address, password]
   foreach $member (@members) {
       my %pair = $self->get_mem_info($member);
       $mem_info_list{$member} = [$pair{'Email Address'}, $pair{'Password'}, $pair{'Priv'}];
   }
   return %mem_info_list;
}

1;
