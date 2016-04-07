# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub command {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $query = $asn->{'Query'};
    $_ = $query->param('suboption');
FRAME: {
    /^listing/ &&
        do {
            $self->listing();
            last FRAME;
           };

    /^writing/ &&
        do {
            $self->writing($query->param('block'),$query->param('question'));
            last FRAME;
           };

    /^List/ &&
        do {
            $self->print_listing();
            last FRAME;
           };

    /^Editor/ &&
        do {
            CN_UTILS::print_cn_header('Editor');
            CN_UTILS::print_cn_footer();
            last FRAME;
           };

    /^Help/ &&
        do {
            CN_UTILS::print_cn_header('Help');
            CN_UTILS::print_cn_footer();
            last FRAME;
           };
    $self->print_help($_);
    }
}

1;
