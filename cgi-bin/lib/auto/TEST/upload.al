# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub upload {
    my ($self,$url) = @_;

    my $hfile = ASSIGNMENT->upload($self,$url);
    if ($hfile =~ /\s*<CN_BLOCK/) {
        $self->uploadCN($hfile);
    } else {
        $self->uploadHTML($hfile);
    }
}

1;
