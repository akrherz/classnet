# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub send_edit_form {
    my ($self,$query,$stu) = @_;
    my $nstu = @{$stu};
    if ($nstu != 1) {
       ERROR::print_error_header('Edit?');
       print "Please select only one student.";
       CN_UTILS::print_cn_footer();
       exit(0);
    }
    # find graded forecasts and display for user to choose
    CN_UTILS::print_cn_header('Graded Forecasts');
    print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/forecast">
<INPUT TYPE=hidden NAME=fc_option VALUE="Edit Answer">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$query->{'Ticket'}->[0]">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
<CENTER>
Select the forecast you want to edit:<P>
<H4><SELECT NAME=Forecasts SIZE=10>
FORM
    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $fname (@files) {
        $fname = CGI::unescape($fname);
        print "<OPTION>$fname\n";
    }
    print "</SELECT>";
    print "<P><INPUT TYPE=submit NAME=Edit VALUE=Edit></H4></CENTER>\n";
    CN_UTILS::print_cn_footer();
    exit(0);
}

1;
