# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub mail_raw_data {
    my ($class, $self, $stud_names) = @_;
    # Handle both method and legacy calls
    if (ref($class)) { $stud_names = $self; $self = $class; }
    my $inst = $self->{'Member'};
    my $cls = $self->{'Class'};
    my $body = '';
    foreach $sname (@{$stud_names}) {
       my $dname = CN_UTILS::get_disk_name($sname);
       $self->{'Ungraded Dir'} = "$cls->{'Root Dir'}/students/$dname/ungraded";
       $self->{'Graded Dir'} = "$cls->{'Root Dir'}/students/$dname/graded";
       $self->{'Java Dir'} = "$cls->{'Root Dir'}/students/$dname/java/$self->{'Disk Name'}";
       $self->{'Dialog Dir'} = "$cls->{'Root Dir'}/students/$dname/dialog";
       $body .= $self->format_raw_data($sname);
    }
    # open (DATA,">/local1/rawdata.dat") || die "Can't open rawdata";
    # print DATA $body;
    # close DATA;
    CN_UTILS::mail($inst->{'Email Address'},"Raw Data for $self->{'Name'}",$body);
}

1;
