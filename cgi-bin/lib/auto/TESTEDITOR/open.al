# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub open {
    my ($self) = @_;
    my $asn = $self->{'Assignment'};
    my $cls = $asn->{'Class'};
    my $develop = "$cls->{'Root Dir'}/assignments/.develop";
    my $flag = "$develop/.flag";
    # remove flag to tell when in editor
    if (-e $flag) {
        unlink $flag;
    }
    # since answers are likely to change, delete key
    # it will be regenerated when grading occurs
    $asn->delete_key();
    $url = $self->URL_edit_string();
    # create document to define window frames
    # the window is divided into three frames
    #---------------------------
    #| listing |    editor     |
    #|         |               |
    #|         |               |
    #---------------------------
    #|     help                |
    #---------------------------
    print <<"FRAMES";
Content-type: text/html

<HTML>
<HEAD>
  <TITLE>Test Editor</TITLE>
</HEAD>
<frameset rows="*,50">
  <frameset cols="*,2*">
    <frame name="listing" src="$url&suboption=List">
    <frame name="editor" src="$GLOBALS::SERVER_ROOT/editor_frame.html">
  </frameset>    
  <frame name="help" src="$GLOBALS::SERVER_ROOT/asn_edit_help.html">
<noframes>
<BODY>
  Sorry! This document cannot be viewed without a frames-capable
  browser.
</BODY>
</noframes>
</frameset>
</HTML>
FRAMES
}

1;
