# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub create {
   my ($self) = @_;

   # Does this class already exist?
   if ($self->exists()) {
       ERROR::user_error($ERROR::CLASSEX,$self->{'Name'});
   }

   # Create the directories
   $self->create_dir_structure();

}

1;
