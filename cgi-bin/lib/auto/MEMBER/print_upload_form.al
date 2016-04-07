# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

sub print_upload_form {
   my ($self, $cls) = @_;

   # Must be owner
   if (!($self->{'Priv'} =~ /students/ || $self->{'Priv'} =~ /owner/)) {
      &ERROR::user_error($ERROR::NOPERM);
   }

   # Get the form;
   CN_UTILS::print_cn_header("Upload");
   print <<"HTML";
<FORM ENCTYPE="multipart/form-data" METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/membership>
<INPUT TYPE=hidden NAME=cn_option VALUE="Perform Upload">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$cls->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$self->{'Ticket'}">
<CENTER><H3>$cls->{'Name'}</H3></CENTER>
<CENTER><img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif"></CENTER>
The <B>Upload</B> option enrolls or deletes students by reading
a file which contains the enrollment information.
(See Help for details.)
<HR>
Enter the local filename or URL below then click on Upload:
<P>
<PRE>
<B>Remote URL:</B> <INPUT NAME=urlname TYPE=text SIZE=40>
<B>Local File:</B> <INPUT NAME=filename TYPE=file SIZE=40>
</PRE>
<CENTER>
<H4>
<INPUT TYPE=submit Value=Upload> <INPUT TYPE=reset> 
<INPUT TYPE=submit name=back VALUE="Members Menu">
</H4>
</CENTER>
HTML
   CN_UTILS::print_cn_footer("upload_members.html");
}

1;
