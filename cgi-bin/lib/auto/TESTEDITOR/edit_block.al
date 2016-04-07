# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub edit_block {
    my ($self,$b) = @_;
    my $asn = $self->{'Assignment'};
    my %params = $asn->read_block($b);

    $name = $params{'Name'};
    $pcredit = $params{'PP'};
    $tcredit = $params{'TP'};
    $btext = $params{'btext'};

    $self->print_edit_header();
    $self->print_start_form();
    print <<"BLOCK";
<INPUT TYPE=hidden NAME=section_type VALUE=blk>
<INPUT TYPE=hidden NAME=suboption VALUE=writing>
<INPUT TYPE=hidden NAME=block VALUE=$b>
<CENTER>
Name <INPUT TYPE=text SIZE=20 NAME=name VALUE="$name" MAXLENGTH=20>
<HR>
<H3>Credit</H3>
Total <INPUT TYPE=text SIZE=5 NAME=tcredit VALUE="$tcredit"> 
Partial <INPUT TYPE=text SIZE=5 NAME=pcredit VALUE="$pcredit">
<HR>
<H3>Preface</H3>
<TEXTAREA NAME=btext COLS=50 ROWS=10>
$btext
</TEXTAREA>
<H4>
<INPUT TYPE=submit NAME=save VALUE=Save> 
<INPUT TYPE=reset  NAME=reset VALUE=Reset> 
<INPUT TYPE=submit NAME=back VALUE=Cancel>
</H4>
</CENTER>
BLOCK
    $self->print_footer();
}

1;
