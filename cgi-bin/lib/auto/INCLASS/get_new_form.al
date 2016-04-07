# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub get_new_form {
   my ($self,$memtype,$submit) = @_;
   my %params = $self->read();
   $self->{'TP'} = $params{'TP'};
   $self->{'PR'} = 0;
   $self->write_test('graded');
}

1;
