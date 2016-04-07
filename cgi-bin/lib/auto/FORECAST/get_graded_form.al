# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_graded_form {
    my $self = shift;
    # find ungraded forecasts and grade
    $self->grade_forecasts($self->{'Ungraded Dir'});
    # find graded forecasts and display for user to choose
    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    my $n = @files;
    if ($n == 0) {
        CN_UTILS::print_cn_header("Forecasts?");
        print "You don't have any graded forecasts yet.";
        CN_UTILS::print_cn_footer();
        exit(0);
    }
    my $query = $self->{'Query'};
    CN_UTILS::print_cn_header('Forecast Answers');
    print <<"FORM";
<FORM METHOD=POST ACTION="$GLOBALS::SCRIPT_ROOT/forecast">
<INPUT TYPE=hidden NAME=fc_option VALUE="Show Answers">
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Class'}->{'Name'}">
<INPUT TYPE=hidden NAME="Assignment Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$query->{'Ticket'}->[0]">
<INPUT TYPE=hidden NAME="Student Username" VALUE="$self->{'Member'}->{'Username'}">
<CENTER>
Select the forecast you want answers for:<P>
<H4><SELECT NAME=Forecasts SIZE=10>
FORM
    foreach $fname (@files) {
        $fname = CGI::unescape($fname);
        print "<OPTION>$fname\n";
    }
    print "</SELECT>";
    print "<P><INPUT TYPE=submit NAME=Answers VALUE=Answers></H4></CENTER>\n";
    CN_UTILS::print_cn_footer();
    exit(0);
}

1;
