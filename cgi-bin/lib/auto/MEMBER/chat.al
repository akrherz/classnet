# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

sub chat {
    my ($self,$cls) = @_;
    my $cname = CGI::escape($cls->{'Name'});
    my $ticket = CGI::escape($self->{'Ticket'});
    # call the assignments script to process command
    my $url .= "&Class+Name=$cname";
    $url .= "&Ticket=$ticket";

    print <<"HTML";
Content-type: text/html

<HTML>
<HEAD>
  <TITLE>$class Chat</TITLE>
</HEAD>
<frameset rows="3*,*">
  <frame name=comment src="chat?chat_option=Comment$url">
  <frame name=entry src="chat?chat_option=Entry$url">
<noframes>
<BODY>
  Sorry! This document cannot be viewed without a frames-capable
  browser.
</BODY>
</noframes>
</frameset>
</HTML>
HTML
}

1;










1;
