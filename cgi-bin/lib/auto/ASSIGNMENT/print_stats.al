# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub print_stats {
    my ($self,$stud_names) = @_;
    my %stats = {};
    my %tot = {};
    my $cls = $self->{'Class'};
    foreach $sname (@{$stud_names}) {
       my $dname = CN_UTILS::get_disk_name($sname);
       $self->{'Ungraded Dir'} = "$cls->{'Root Dir'}/students/$dname/ungraded";
       $self->{'Graded Dir'} = "$cls->{'Root Dir'}/students/$dname/graded";
       $self->grade_ungraded();
       $self->get_stats(\%stats,\%tot);
    }
    $self->format_stats(\%stats,\%tot);
}

1;
