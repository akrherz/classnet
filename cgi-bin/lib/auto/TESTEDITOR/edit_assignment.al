# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub edit_assignment {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my %params = $asn->read();
    my $atype = $params{'Assignment Type'};
    if ($params{'VERS'} > 0) {
        $nver = $params{'VERS'};
        $rand = 0;
    } else {
        $nver = '';
        $rand = 1;
    }
    $extra_fields = $asn->get_extra_fields();
    $ansall  = $EDITOR::checked[$params{'FILL'}];
    $letview = $EDITOR::checked[$params{'VIEW'}];
    $mult    = $EDITOR::checked[$params{'MULT'}];
    $duedate = $params{'DUE'};
    $pass = $params{'PASSWORD'};
    $tp = $params{'TP'};
    $publish = $EDITOR::checked[!($asn->{'Dev Root'} =~ /.develop/)];
    $self->print_edit_header();
    $self->print_start_form();
    print <<"ASSIGN";
<INPUT TYPE=hidden NAME="Assignment Type" VALUE="$atype">
<INPUT TYPE=hidden NAME=section_type VALUE=asn>
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<INPUT TYPE=hidden NAME=TP VALUE=$tp>
<CENTER>
<H3>Assignment $asn->{'Name'}</H3>
(Type $atype)
<HR>
<H3>Question Selection</H3> 
<INPUT TYPE=radio NAME=rand VALUE=rand $EDITOR::checked[$rand]> Random
<INPUT TYPE=radio NAME=rand VALUE=vers $EDITOR::checked[!$rand]> Versions 
<INPUT TYPE=text NAME=versions SIZE=2 VALUE="$nver">
<HR>
<H3>Student Answer Options</H3>
<INPUT TYPE=checkbox NAME=fill VALUE=fill $ansall> Answers all questions
<INPUT TYPE=checkbox NAME=view VALUE=view $letview> View correct answers
<HR>
<H3>Due Date</H3>
(hh:mm:mn/dd/yyyy)<BR>
<INPUT TYPE=text NAME=duedate SIZE=16 VALUE=$duedate>
<HR>
<H3>Proctor Options</H3>
Password<BR>
<INPUT TYPE=password NAME=password SIZE=16 VALUE="$pass"><BR>
<INPUT TYPE=checkbox NAME=mult VALUE=mult $mult> Allow multiple tries 
<HR>
<INPUT TYPE=checkbox NAME=publish VALUE=Publish $publish> Publish 
<HR>
$extra_fields
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save>
<INPUT TYPE=reset  NAME=reset VALUE=Reset> 
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
ASSIGN
    $self->print_footer();
}

1;
