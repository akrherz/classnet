# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub renew {
    my ($self) = @_;
    system("rm -f $self->{'Root Dir'}/admin/members/students/*");
    system("rm -f $self->{'Root Dir'}/admin/members/requests/*");
    system("rm -f $self->{'Root Dir'}/admin/member_lists/students");
    system("rm -rf $self->{'Root Dir'}/students/*");
    system("rm -f $self->{'Root Dir'}/chat");
    system("rm -f $GLOBALS::FORUM_DIR/$self->{'Disk Name'}/topics/*");
    system("rm -f $GLOBALS::FORUM_DIR/$self->{'Disk Name'}/responses/*");
}

1;
