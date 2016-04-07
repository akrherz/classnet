# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub print_renewal {
    my ($self,$inst) = @_;
    
   # Must be owner
   if ($inst->{'Priv'} ne 'owner') {
      ERROR::user_error($ERROR::NOPERM);
   }

   # Get the form;
   CN_UTILS::print_cn_header("Renew Class");
   print <<"HTML";
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Renew">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3></CENTER>
The renew option will <B>delete</B> the following items:
<UL>
<LI>All <B>student</B> records
<LI><B>Chat</B> comments
<LI><B>Discussions</B>
</UL>
<P>
However, all <B>instructor</B> records and <B>assignments</B> will
remain unchanged.
<P>
<CENTER>
<H4>
<INPUT TYPE=submit Value=Renew>
<BR> 
<INPUT TYPE=submit name=memback VALUE="Members Menu">
</H4>
</CENTER>

HTML
   CN_UTILS::print_cn_footer("renew.html");
}

1;
