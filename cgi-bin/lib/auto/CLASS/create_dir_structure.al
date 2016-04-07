# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub create_dir_structure {
   my $self = shift;

   # Create the directories
   mkdir($self->{'Root Dir'},0700) or
       &ERROR::system_error("CLASS","create_dir_structure","mkdir1",$self->{'Root Dir'});
   chdir($self->{'Root Dir'});
   (mkdir('admin',0700) and mkdir('admin/members',0700) and mkdir('admin/member_lists',0700) and
    mkdir('admin/members/requests',0700) and mkdir('admin/members/instructors',0700) and
    mkdir('admin/members/students',0700) and mkdir('assignments',0700) and mkdir('students',0700)) 
       or
   &ERROR::system_error("CLASS","create_dir_structure","mkdir2",$self->{'Name'});
}

1;
