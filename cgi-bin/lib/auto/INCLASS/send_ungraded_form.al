# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub send_ungraded_form {
   my $self = shift;
   ERROR::user_error($ERROR::NOTDONE,"complete the <B>$self->{'Name'}</B>
 assignment since only your instructor can set your score");
}

1;
