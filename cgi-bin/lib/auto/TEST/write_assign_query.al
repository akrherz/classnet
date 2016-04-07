# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub write_assign_query {
   my ($self) = @_;
   my (%assign_params, $answer_all);
   my $query = $self->{'Query'};

   # Read the student's assignment template
   $self->read_test();

   # Read the options file
   %assign_params =  $self->read();
   (defined %assign_params) or
        ERROR::system_error('TEST','write_assign_query','read header',
                            "$self->{'Dev Root'}/options");

   # Do not store if only a single submission is allowed and already submitted

   if (defined $assign_params{'PASSWORD'}) {
       if (!$assign_params{'MULT'} and $self->{'Test Header'}{'SUBMIT'}== 1) {
           ERROR::user_error($ERROR::COMPLETED);
       }
   }

   # Write the Query to the ungraded dir
   $answer_all = $assign_params{'FILL'};
   @q_names = sort {$a <=> $b} (keys %{$self->{'Stud Answers'}});
   foreach $q_name (@q_names) {
       if ( $answer_all and !(defined $query->{$q_name})) {
       	   $q_name =~ m/(\d+)\./;
           # don't report missing answer if MULTIPLE question
           if ($query->param("$1.") eq 'MULTIPLE') {
               $query->{$q_name}->[0] = '0';
           } else {
       	       ERROR::user_error($ERROR::ANSWERNF, $1);
           }
       }
       # Store and remove beginning and ending whitespace
       $self->{'Stud Answers'}{$q_name}{'ANS'} = CN_UTILS::remove_spaces($query->{$q_name}->[0]);
       if (length($query->{$q_name}->[0]) > $GLOBALS::MAX_ANS_LENGTH) {
       	   $q_name =~ m/(\d+)\./;
       	   ERROR::user_error($ERROR::MAXANS, $1);
       }
   }
   $self->write_test('ungraded');
}

1;
