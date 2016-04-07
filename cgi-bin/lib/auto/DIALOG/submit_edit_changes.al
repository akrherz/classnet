# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub submit_edit_changes {
   my ($self,$query) = @_;
   $self->submit($query);
   
}

1;
