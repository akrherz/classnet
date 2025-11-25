# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub send_ungraded_form {
   my $self = shift;
   my ($form,$status,%params);  

   # Check status of assignment
   $status = $self->get_status();
   # Must be ungraded
   ($status eq 'graded') and
       ERROR::user_error($ERROR::GRADED);
   # Get assignment info and check due date
   %params = $self->read();
   (%params) or
        ERROR::system_error('TEST','send_ungraded_form','read header',
                            "$self->{'Dev Root'}/options");
   $self->{'Key Header'} = \%params;
   $self->due_date_past($params{'DUE'}) and
       ERROR::user_error($ERROR::PASTDUE,$params{'DUE'});
   my $due = (defined $params{'DUE'})? "<CENTER>(Due $params{'DUE'})</CENTER><HR>": '';

   if (!$status) {
       # No submission yet
       my $form = $self->get_new_form('student','nosubmit');
       $self->print_base_header();
       print "$due$GLOBALS::HR$form";
   }
   elsif ($status eq 'ungraded') { 
       # Assignment has been submitted but ungraded
       my $form = $self->get_ungraded_form();
       $self->print_base_header();
       print "$due$GLOBALS::HR$form";
   }
   else {
       ERROR::system_error("TEST.pm","send_ungraded_form","$self->{'Name'}","No form found");
   }

   exit(0);
}

1;
