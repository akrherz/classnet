package EDITOR;

#
# abstract type for assignment editors
#

#########
=head1 EDITOR

=head1 Methods:

=cut
#########

@checked = ('','CHECKED');
@selected = ('','SELECTED');


#########################################
=head2 new($asn)

=over 4

=item Description
Create a new editor

=item Params
$asn: ASSIGNMENT object

=item Returns
a new Editor

=back

=cut

sub new {
    my ($class,$asn) = @_;
    my $self = {};
    bless $self, $class;
    $self->{'Assignment'} = $asn;
    return $self;
}

#########################################
=head2 URL_edit_string()

=over 4

=item Description
Create a URL escaped string to call the
editor

=item Params
none

=item Returns
none

=back

=cut

sub URL_edit_string {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $cname = CGI::escape(($asn->{'Class'})->{'Name'});
    my $aname = CGI::escape($asn->{'Name'});
    my $tname = CGI::escape($asn->{'Member'}->{'Ticket'});
    # call the assignments script to process command
    my $url = "$GLOBALS::SERVER_ROOT/cgi-bin/editor";
    # user information
    $url .= "?Class+Name=$cname";
    $url .= "&Ticket=$tname";
    $url .= "&Assignment+Name=$aname";
    $url .= "&cn_option=Command";
    return $url;
}

#########################################
=head2 print_start_form()

=over 4

=item Description
start the editor for this assignment

=item Params
none

=item Returns
none

=back

=cut

sub print_start_form {
    my ($self) = @_;
    $asn = $self->{'Assignment'};
    $query = $asn->{'Query'};
    $cls = $asn->{'Class'};
    $tkt = $query->param('Ticket');
    print <<"INFO";
<FORM METHOD=POST ACTION="$GLOBALS::SERVER_ROOT/cgi-bin/editor">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$tkt">
<INPUT TYPE=hidden NAME=cn_option VALUE=Command>
<INPUT TYPE=hidden NAME="Assignment Name" VALUE=\"$asn->{'Name'}\">
INFO
}

#########################################
=head2 open()

=over 4

=item Description
start the editor for this assignment

=item Params
none

=item Returns
none

=back

=cut

sub open {
    my ($self) = @_;
    CN_UTILS::print_cn_header(ref($self));
    exit(0);
}

#########################################
=head2 command()

=over 4

=item Description
Process an edit command

=item Params
none

=item Returns
none

=back

=cut

sub command {
    my ($self) = @_;
    CN_UTILS::print_cn_header(ref($self));
    exit(0);
}

#########################################
=head2 print_footer()

=over 4

=item Description
Prints the foot of an HTML document

=item Params
none

=item Returns
none

=back

=cut

sub print_footer {
print <<"FOOTER";
</BODY>
</HTML>
FOOTER
}

1;











