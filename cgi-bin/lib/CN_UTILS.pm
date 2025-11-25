package CN_UTILS;

#########################################
=head1 CN_UTILS

=head1 Functions:

=cut
#########################################

require 'ctime.pl';
require ERROR;

$SENDMAIL = '/usr/sbin/sendmail';
$GNUPLOT = '/afs/iastate.edu/project/gnu/bin/axp/gnuplot'; 
$PPMTOGIF = '/afs/iastate.edu/public/pbm/bin/axp/ppmtogif';
$GIFTRANS = '/afs/iastate.edu/project/www/bin/axp/giftrans';

#########################################
=head2 CN_UTILS::print_cn_header($title)

=over 4
=item Description
Print out HTTP header, ClassNet image, and title

=item Params
$title: Title of the HTML document

=back

=cut

sub print_cn_header {
   my $title = shift;
print <<"HEADER";
Content-type:text/html
Window-target: _top

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
   <title>$title</title>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body $GLOBALS::BACKGROUND $GLOBALS::BGCOLOR>
 
<h3><a href="/">Iowa State University ClassNet</a></h3>

<h2>$title</h2>

HEADER
}

sub print_cn_locheader {
   my $title = shift;
   my $loc = shift;
print <<"HEADER";
Content-type:text/html
Window-target: _self
Location: $loc

<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
<BODY $GLOBALS::BACKGROUND $GLOBALS::BGCOLOR>
<P><CENTER><IMG SRC="$GLOBALS::SERVER_IMAGES/classnet.gif"  ALIGN=BOTTOM
ALT="Classnet Banner"></CENTER>
<H2><CENTER>$title</CENTER></H2>
$GLOBALS::HR<p>

HEADER
}
#########################################
=head2 CN_UTILS::print_cn_footer($help_page)

=over 4
=item Description
Print out HTTP footer

=item Params
$help_page: page name containing help (e.g. "help_page_name.html")(optional)
=back

=cut

sub print_cn_footer {
    my ($help_page) = @_;

    print "<H3><CENTER>\n";
    if ($help_page ne "") {
        print $GLOBALS::RED_BALL;
        print " <A HREF=\"$GLOBALS::HELP_ROOT/$help_page\">Help </A>\n";
    } 

    print "</CENTER></H3>\n";
    print "<div id=\"footer\">\n";
    print "Copyright &copy; 1996-2004, <A HREF=\"http://www.iastate.edu/\">Iowa State University</A>. All rights reserved.\n";
    print "</div>\n</body>\n</html>";
 
}

#########################################
=head2 CN_UTILS::verify_pairs($query, @names)

=over 4
=item Description
Verify that required HTML pairs exist on the incoming form 

=item Params
$query: CGI parsed form object 

@names: List of required form names 

=item Returns
If a required name/value pair is missing, the script dies, and 
the user is notified which name is needed. 

=back

=cut

sub verify_pairs {
   my ($query_obj, @names) = @_;
   foreach $name (@names) {
       $query_obj->param($name) or
       	   &ERROR::user_error($ERROR::FIELDNF,$name);
   }
}

#########################################
=head2 CN_UTILS::get_disk_name($name)

=over 4
=item Description
Convert a name to its disk representation. This will be used
for usernames and course names. The changes are hex
conversion of possible dangerous characters, removal of 
beginning and trailing whitespace, and conversion of all
letters to upper case.

=item Params
$name: Unmodified user entered name

=item Returns
The disk representation of $name

=back

=cut

sub get_disk_name {
   my $disk_name = shift;

   $disk_name = CN_UTILS::remove_spaces($disk_name);
   $disk_name = CGI::escape($disk_name);

}   

#########################################
=head2 CN_UTILS::remove_spaces($name)

=over 4
=item Description
Removes beginning and trailing whitespace

=item Params
$name: Unmodified name

=item Returns
modified $name

=back

=cut

sub remove_spaces {
   my $name = shift;

   $name =~ s/\s*(.*)/$1/;
   $name = reverse $name;
   $name =~ s/\s*(.*)/$1/;
   reverse $name;

}   

#########################################
=head2 CN_UTILS::mail($destination,$subject,$body)

=over 4
=item Description
Send the mail message in $body with $subject to $destination

=item Params
$destination: email address of recepient
$subject: text of subject line
$body: text of body

=item Returns
none

=back

=cut

sub mail {
  my($destination,$subject,$body) = @_;
open (MAIL,"| $SENDMAIL -t -oi -f akrherz\@iastate.edu") || die ("$SCRIPT: Can't open $mailprog: $!\n"); print MAIL "To: $destination\n";
print MAIL "Reply-to: $GLOBALS::ADMIN_EMAIL\n";
print MAIL "From: $GLOBALS::ADMIN_EMAIL\n";
print MAIL "Subject: $subject\n";
# Don't ask me why, but I had to put another \n before
# the body. Else everything gets stuck on the subject line
print MAIL "\n$body\n";
close MAIL;
}  

#########################################
=head2 CN_UTILS::hasTables()

=over 4
=item Description
Returns true if the browser supports tables

=item Params
none

=item Returns
none

=back

=cut

sub hasTables {
    return ($ENV{'HTTP_USER_AGENT'} =~ m/Mozilla|aolbrowser|SPRY/i);
}

#########################################
=head2 CN_UTILS::plot($file)

=over 4
=item Description
Generates a gif file

=item Params
$file: name of datafile

=item Returns
none

=back

=cut

sub plot {
    my ($fname,$parms) = @_;
    $|=1;  # to prevent buffering problems

    my $gname = "/local/classnet/html/tmpgifs/$$.gif";
    # | $GIFTRANS -t#ffffff
    open (GRAPH,"| $GNUPLOT | $PPMTOGIF | cat >$gname") 
      or return "can't open $gname: $!\n";
    foreach $cmd (@{$parms}) {
        print GRAPH "$cmd\n";
    }
    close GRAPH;
    return "$GLOBALS::SECURE_ROOT/tmpgifs/$$.gif";
}

#########################################
=head2 CN_UTILS::getTime($file)

=over 4
=item Description
Get the modification time of a file

=item Params
$file: name of file

=item Returns
String time of modification

=back

=cut

sub getTime {
    my ($fname) = @_;
    my @ary = stat($fname);
    my $dt = &ctime($ary[9]);
    chop $dt;
    return $dt;
}

#########################################
=head2 CN_UTILS::currentTime()

=over 4
=item Description
Get the current tile

=item Params
none

=item Returns
String current time

=back

=cut

sub currentTime {
    my $dt = &ctime(time);
    chop $dt;
    return $dt;
}
1;
