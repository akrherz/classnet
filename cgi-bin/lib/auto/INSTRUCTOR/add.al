# NOTE: Derived from lib/INSTRUCTOR.pm.  Changes made here will be lost.
package INSTRUCTOR;

#__DATA__

#########################################

sub add {

   my($self, $cls, $priv) = @_;

   # Username must be unique
   $mem_type = $cls->mem_exists($self->{'Disk Username'});
   if ($mem_type) {
     &ERROR::user_error($ERROR::MEMBEREX,$self->{'Username'});
   }

   chdir("$self->{'Root Dir'}/admin/members/instructors");
   open(INST_FILE, ">$self->{'Disk Username'}") or 
     &ERROR::system_error("INSTRUCTOR","add","Open",self->{'Disk Username'});
   print INST_FILE "Password=$self->{'Password'}\n";
   print INST_FILE "Email Address=$self->{'Email Address'}\n";
   print INST_FILE "Priv=$priv\n";
   close(INST_FILE) or
     &ERROR::system_error("INSTRUCTOR","add","Close",self->{'Disk Username'}); 
   chmod(0600, $self->{'Disk Username'});
   $cls->add_to_mem_list('instructor',$self->{'Username'});

}

1;
