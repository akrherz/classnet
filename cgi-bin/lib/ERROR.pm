package ERROR;

###############################
=head1 ERROR

=head1 Methods;

=cut
*******************************

require GLOBALS;
require CN_UTILS;

# global user error message constants
$FIELDNF = "Missing or Incorrect Information";
$PWDVERIFY = "Incorrect Password Information";
$PWDBAD = "Incorrect Password";
$CLASSEX = "Class exists";
$CLASSAPPROVAL = "Class Waiting for Approval";
$CLASSNF = "Class not found";
$CNERROR = "ClassNet Server Problem";
$CLASSLIMIT = "Class Limit Exceeded";
$MEMBERLIMIT = "Member Limit Exceeded";
$NOPERM = "No Permission";
$ENROLL = "Enrollment must be approved";
$ENROLLREQ = "Enrollment request submitted";
$MEMBERNF = "Member not found";
$MEMBEREX = "Member already enrolled";
$EMAILEX = "Email address already used";
$ASSIGNEX = "Assignment already exists";
$ASNNOVIEW = "Assignment may not be viewed";
$NOOPTION = "No option available";
$NOTDONE = "Operation not done";
$DONE = "Operation done";
$FORMNF = "Assignment form not found";
$NOREQUEST = "No approval requests are outstanding";
$RESWORD = "ClassNet Reserved Word";
$NOMETHOD = "No method defined";
$NOASNTYPE = "No assignment type";
$ANSWERSNF = "Missing answer";
$PASTDUE = "Due date past";
$GRADED = "Assignment graded";
$UNGRADED = "Assignment not graded";
$NOSTUDNAMES = "No student names specified";
$NOASNNAMES = "No assignment names specified";
$MAXANS = "Maximum answer length reached";
$CLOSED = "Class is closed to enrollment";
$COMPLETED = "Assignment already completed";
$BADNAME = "Name may only include letters or digits";
$NOTICKET = "Session has expired.";

# local constants
$RETRY = "<P>Click on <B>Back</B> in your browser and try again.";
$CONSTRUCT = "<img src=\"$GLOBALS::SERVER_IMAGES/construction.gif\" ALT=\"Under Construction\">";

%err_msg = (
$FIELDNF,
"Please complete or correct information for <B>%s</B>.$RETRY",

$PWDVERIFY,
"The values you entered for password and verify password are not the 
same.$RETRY",

$PWDBAD,
"The password you entered is incorrect. UPPER and lower case 
letters are important.  Check your CAPS LOCK key.$RETRY<BR>If you continue to have 
trouble, contact your instructor (for students) or ClassNet administrator (for instructors) to change your password.",

$CLASSEX,
"Class <i>%s</i> already exists. Try a different name for your class.$RETRY",

$CLASSAPPROVAL,
"Class <b>%s</b> is already waiting creation approval.<BR>Please wait for
email notification from ClassNet administrators.",

$ASSIGNEX,
"Assignment <i>%s</i> already exists. Try a different name.$RETRY",

$ASNNOVIEW,
"Your instructor has not granted permission to view assignment <i>%s</i>.",

$CLASSNF,
"Class <i>%s</i> doesn't exist. Try another name.$RETRY",

$CLASSLIMIT,
"ClassNet class limit ($GLOBALS::MAX_CLASS) has been reached. See the ClassNet administrator.",

$MEMBERLIMIT,
"ClassNet member limit ($GLOBALS::MAX_STUDENTS) has been reached. See the ClassNet administrator.",

$NOPERM,
"You aren't allowed to do that.",

$ENROLL,
"Your enrollment must be approved by your instructor before you can proceed.",

$ENROLLREQ,
"Your enrollment request has been submitted to your instructor. The 
instructor must approve this request before you can perform any 
activities. You will be notified by email when your request is approved.",

$MEMBEREX,
"Member <i>%s</i> is already enrolled. Try a different version of your name.$RETRY",

$EMAILEX,
"Email address <i>%s</i> is already used by another user.$RETRY",

$CNERROR,
"An error in ClassNet has occurred. The ClassNet adminstrator has been notified. Try again later.",

$MEMBERNF,
"Member <i>%s</i> isn't enrolled.$RETRY",

$FORMNF,
"The URL <i>%s</i> was not found.$RETRY",

$NOCHANGE,
"You didn't request any changes.",

$NOTICKET,
"Your session has expired.  Please <a href=\"$GLOBALS::SCRIPT_ROOT/main-menu\">login</a> again.",

$NOOPTION,
"The option you specified is not available.$RETRY",

$NOTDONE,
"Unable to %s.",

$DONE,
"%s",

$RESWORD,
"A ClassNet reserved word was found: %s. %s",

$NOREQUEST,
"No approvals are required at this time.",

$NOMETHOD,
"You must define a method for %s.",

$NOASNTYPE,
"No assignment type defined for  %s.",

$ANSWERNF,
"ALL questions must be answered (See question %s?). Assignment not stored! $RETRY",

$PASTDUE,
"Sorry, the due date of <b>%s</b> has past.",

$GRADED,
"This assignment has already been graded. Please view answers or scores.",

$UNGRADED,
"This assignment has not been graded by ClassNet. No answers may be displayed. <br>%s",

$NOSTUDNAMES,
"Please select student name(s).",

$NOASNNAMES,
"Please select assignment name(s).",

$MAXANS,
"Answer size limit reached (See question %s?). Assignment not stored.",

$CLOSED,
"Sorry but this class is closed to enrollment. Please see the instructor.",

$BADNAME,
"Please include only letters or digits in '%s'.$RETRY",

$CONSTRUCT,
"This page is under construction. Try again later.",

$COMPLETED,
"You have previously viewed this assignment. Proctored assignments may
only be viewed once.",

);

=cut

**********************************
=head2 print_error_header($title)

=over 4

=item Description
Prints header for errors

=item Params
$title: Title of error

=item Returns
Exits

=back

=cut

sub print_error_header {
  my ($title) = @_;

  print <<"HEADER";
Content-type: text/html
Window-target: _top

<HTML>
<HEAD>
<TITLE>$title</TITLE>
</HEAD>
<BODY $GLOBALS::BACKGROUND $GLOBALS::BGCOLOR>
<P>
<CENTER>
<IMG SRC="$GLOBALS::SERVER_IMAGES/classnet.gif"
ALIGN=BOTTOM NATURALSIZEFLAG=0 ALT="Classnet Banner">
<H4>$title</H4>
$GLOBALS::HR
</CENTER>
HEADER

}

=cut

**********************************
=head2 user_error($msg_name, @info)

=over 4

=item Description
Reports error to user in HTML form and then dies

=item Params
$msg_name: Name of message from global constants defined above
@info: Any additional information needed by message

=item Returns
Exits

=back

=cut

sub user_error {
  my ($msg_name,@info) = @_;
  print_error_header($msg_name);
  print "<CENTER><img src=\"$GLOBALS::SERVER_IMAGES/warning.gif\"></CENTER><P>\n";
  printf("$err_msg{$msg_name}\n",@info);
  print <<"FOOTER";
$GLOBALS::HR
</BODY>
</HTML>
FOOTER
  exit(0);
}

=cut

**********************************
=head2 constr()

=over 4

=item Description
Displays construction user error

=item Returns
Exits

=back

=cut

sub constr {
  user_error($CONSTRUCT);
}

=cut

**********************************
=head2 user_msg(@msg)

=over 4

=item Description
Reports message to user in HTML form and then dies

=item Params
@msg: Text of message

=item Returns
Just dies

=back

=cut

sub user_msg {
  my (@msg) = @_;
  user_error($DONE,@msg);
}

=cut

**********************************
=head2 system_error($file_name,$sub_name,$op_name,@info)

=over 4

=item Description
Sends generic user_error to user, mails specific error to administrator
and appends error to log.

=item Params
$file_name: Name of file which contains error code
$sub_name: Procedure which contains error code
$op_name: Name of operation being performed (open, close etc.)
@info: Additional useful information

=item Returns
Just dies

=back

=cut

sub system_error {
    my ($file_name,$sub_name,$op_name,@other) = @_;
    my $sys_err = $! ? " (system error: $!)" : "";
    print_error_header(${$CNERROR});
    print "$err_msg{$CNERROR}\n";
    print "<BR><b>System error:</b> $!<BR>" if $!;
    print <<"FOOTER";
<CENTER>$GLOBALS::HR</CENTER>
</BODY>
</HTML>
FOOTER

    $logname = "$GLOBALS::SERVER_LOG_DIR/classnet.log";
    open(ERR_LOG, ">>$logname");
    print ERR_LOG "----------\n";
    #$tm = &ctime::ctime(time);
    print ERR_LOG "$tm";
    print ERR_LOG "${file_name}::$sub_name($op_name)$sys_err\n";
    print ERR_LOG "Other: @other\n";
    $i = 0;
    while (($pack,$file,$line,$subname) = caller($i++)) {
        print ERR_LOG "$pack,$file,$line,$subname\n";
    }
    close(ERR_LOG);
    CN_UTILS::mail($GLOBALS::SYSTEM_EMAIL,'ClassNet System Error',
    "--------\n${file_name}::$sub_name($op_name)$sys_err\n@other\n");
    die;
}

=cut

**********************************
=head2 check_sample($query,$msg)

=over 4

=item Description
Reports message if the Class Name is Sample Class and exists

=item Params
$query: CGI query object
$msg: Text of operation being attempted 

=item Returns
Exits

=back

=cut

sub check_sample {
  my ($query,$msg) = @_;
  if ($query->param('Class Name') ne 'Sample Class') {
      return;
  }
  print_error_header($msg);
  print "<CENTER><img src=\"$GLOBALS::SERVER_IMAGES/warning.gif\"></CENTER><P>\n";
  print <<"FOOTER";
The operation to <B>$msg</B> would normally be completed at this time,
but won't actually be performed since you are using the Sample class.
Press <B>Back</B> to continue exploring. 
$GLOBALS::HR
</BODY>
</HTML>
FOOTER
  exit(0);
}

1;







