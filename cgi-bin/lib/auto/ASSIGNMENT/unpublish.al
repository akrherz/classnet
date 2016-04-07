# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub unpublish {
    my ($self) = @_;
    if (!($self->{'Dev Root'} =~ /.develop/)) {
        my $cls = $self->{'Class'};
        my $dir = "$cls->{'Root Dir'}/assignments/.develop/$self->{'Disk Name'}";
        rename($self->{'Dev Root'},$dir);
        $self->{'Dev Root'} = $dir;
    }
}

1;
