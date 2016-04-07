# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub print_listing {
    my ($self) = @_;
    $asn = $self->{'Assignment'};
    $cname = $asn->{'Class'}->{'Name'};
    $aname = $asn->{'Name'};
    print <<"LIST";
Content-type: text/html
Window-target: listing

<HTML>
<HEAD>
  <TITLE>$title</TITLE>
</HEAD>
<BODY $GLOBALS::BACKGROUND $GLOBALS::BGCOLOR>
<CENTER><h2>Sections</h2></CENTER>
LIST
    $self->print_start_form();
    print <<"LIST";
<INPUT TYPE=hidden NAME=suboption VALUE=listing>
<CENTER>
<SELECT SIZE=15 NAME=section>
<OPTION>$aname
LIST
# get number of blocks
$nblk = $asn->block_count();
for ($b = 1; $b <= $nblk; $b++) {
    %params = $asn->read_block($b);
    print "<OPTION>$b $params{'Name'}\n";
    $nq = $asn->question_count($b);
    for ($q = 1; $q <= $nq; $q++) {
        print "<OPTION>$b.$q\n";
    }
}

print <<"FOOTER";
</SELECT>
<P>
<H4>
<INPUT TYPE=submit NAME=listing VALUE=Edit>
<INPUT TYPE=submit NAME=listing VALUE=Add>
<BR>
<INPUT TYPE=submit NAME=listing VALUE=Cut>
<INPUT TYPE=submit NAME=listing VALUE=Copy>
<INPUT TYPE=submit NAME=listing VALUE=Paste>
<BR>
<INPUT TYPE=submit NAME=listing VALUE=View>
<BR>
<INPUT TYPE=submit NAME=back VALUE="Assignments Menu">
</H4>
<P>
$GLOBALS::RED_BALL <a HREF="$GLOBALS::SERVER_ROOT/help/edit_test.html" target=Help>Help</a>
</CENTER>
</FORM>
</BODY>
</HTML>
FOOTER
}

1;
1;
