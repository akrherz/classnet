# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

sub check_password {
   my ($self, $query) = @_;
   ($self->{'Password'} eq $query->{'Password'}->[0]) or
       ERROR::user_error($ERROR::PWDBAD);
}

1;
