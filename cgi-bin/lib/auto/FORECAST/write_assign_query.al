# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub write_assign_query {
   my ($self) = @_;
   my $query = $self->{'Query'};
   # see if it is stored in option or list
   my $site = CN_UTILS::remove_spaces($query->param('1.1'));
   if ($site eq '') {
       # assume it is a text field and search for station code in database file
       $site = CN_UTILS::remove_spaces($query->param('1.1.1'));
   }
   my $found = 0;
   $/ = "\n";
   open(SITES,"<$SITE");
   while(<SITES>) {
     chop;
     if (/^$site$/i) {
        $found = 1;
	break;
     }
   }
   close(SITES);
   # verify site selection and call parent
   if (!$found) {
       ERROR::print_error_header("Station Code?");
       print "<B>'$site'</B> is not a valid 4 letter site code. <BR>Click on
Back and enter a correct station code.\n";
       CN_UTILS::print_cn_footer();
       exit(0);
   }
   TEST::write_assign_query($self);
}

1;
