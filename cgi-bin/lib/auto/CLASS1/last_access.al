# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub last_access {
    my ($self) = @_;
    my $msg = '';
    my $forum = CN_UTILS::get_disk_name($self->{'Name'});
    $file = "$GLOBALS::FORUM_DIR/$forum/topics";
    if (-e $file) {
        my $dt = CN_UTILS::getTime($file);
        $msg .= "Last Discuss topic added on $dt<BR>";
    }
    my $file = "$self->{'Root Dir'}/chat";
    if (-e $file) {
        my $dt = CN_UTILS::getTime($file);
        $msg .= "Last Chat on $dt<BR>";
    }
    return $msg;
}

1;
