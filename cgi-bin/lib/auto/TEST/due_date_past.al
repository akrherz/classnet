# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub due_date_past {
   my ($self,$due_date) = @_;

   # Look in the header if no due date passed in
   if (!(defined $due_date)) {
       !(defined $self->{'Key Header'}) and
       	   $self->{'Key Header'} = $self->read();
       (defined $self->{'Key Header'}) or
            ERROR::system_error('TEST','due_date_past','read header',
                                "$self->{'Dev Root'}/options");
       $due_date = $self->{'Key Header'}{'DUE'};
   }

   # Get approx # of due days
   # If no due date, assigns are never late
   my ($due_hr, $due_min, $due_rest) = split(/:/,$due_date);
   if ($due_hr eq $due_date) {
      $due_hr = 0; $due_min = 0;
   } else {
      $due_date = $due_rest;
   }
   my ($due_mon, $due_day, $due_year) = split(/\//,$due_date);
   !$due_mon and
       return 0;
   $due_tot = $due_day + (31 * $due_mon) + ($due_year * 12 * 31);

   # Get approx # of current days
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   $mon+=1;
   $year+=1900;
   # Check for year 2000+. This check was in but not needed. (12/1/98)
   #($year < 1996) and 
   #    $year+=100;
   $cur_tot = $mday + ($mon * 31) + ($year * 12 * 31); 
   # convert both to minutes
   $cur_tot = 60 * (24 * $cur_tot + $hour) + $min;
   $due_tot = 60 * (24 * $due_tot + $due_hr) + $due_min;
   return ($cur_tot > $due_tot);
}

1;
