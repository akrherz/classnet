package FORECAST;
use Exporter;
use AutoLoader;
@ISA = (Exporter, AutoLoader, TEST);
#@ISA = qw( TEST );

#########
=head1 FORECAST

=head1 Methods:

=cut
#########

require TEST;

$CACHE = '/local/classnet/weather/cache';
$RAWDIR = '/fcst';
$SITE= '/local/classnet/weather/sites.dat';

@months = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec);

#########################################
=head2 new($query, $cls, $member, $assign_name)

=over 4

=item Description

=item Params

=item Instance Variables

=item Returns
FORECAST object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $assign_name) = @_;
   my $self = TEST->new($query,$cls,$member,$assign_name);
   bless $self, $class;

   if ($assign_name =~ /(\d{2})(\w{3})(\d{4})/) {
       # since this is an actual forecast, we will fake it for now
       $self->{'Form Root'} = "$cls->{'Root Dir'}/assignments/$self->{'Disk Name'}";
       $self->{'Dev Root'} = $self->{'Form Root'};
       $self->{'Key Path'} = "$self->{'Form Root'}/key";
   } else {
       # if it uses an archived dataset then it is in assignment directory
       my $fname = "$self->{'Dev Root'}/archive.dat"; 
       if (-e $fname) {
           $self->{'Student File'} = $self->{'Disk Name'};
       } else {
           # the student file name is based on today's date
           ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
           # handle year2000 problem
           #if ($year < 100) {
           #    $year += ($year < 96)? 2000:1900;
           #}
           # the above seems wrong anyway
           $year += 1900;
           $self->{'Student File'} = sprintf("%02d$months[$mon]%04d",$mday,$year);
       }
   }
   # note that the key path points to assignment_name/key
   return $self;
}

__END__

#########################################
=head2 create()

=over 4

=item Description
Create an TEST

=item Params
none

=item Returns
none

=back

=cut

sub create {
    my ($self) = @_;
    ASSIGNMENT::create($self);
    my $dir = $self->{'Dev Root'};
    system("cp -r /local1/weather/Forecast/* $dir");
}

#########################################
=head2 get_wx_filename()

=over 4

=item Description
Get the name of the data file containing actual weather

=item Params
none

=item Returns
none

=back

=cut

sub get_wx_filename {
    my ($self) = @_;
    
    my $fname = $self->{'Student File'};
    if ($fname =~ /(\d{2})(\w{3})(\d{4})/) {
        $day = $1; $mon=$2; $year=$3;
        for($i=0;$i < 12 && $mon ne $months[$i]; $i++){};
        $mon = $i;
    } elsif ($fname =~ /(\d{2})(\d{2})(\d{2})/) {
        $day = $1; $mon=$2; $year=$3;
    } else {
        # it is an archived dataset
        return $fname;
    }
    return sprintf("%04d%02d%02d",$year,$mon+1,$day);
}

#########################################
=head2 grade()

=over 4

=item Description
Grade this forecast. Get runtime weather data
and store in runtime values.

=item Params
none

=item Returns
none

=back

=cut

sub grade {
    my ($self) = @_;

    undef $self->{'Runtime Values'};
    $self->TEST::grade() if (defined($self->get_runtime_values()));
}

#########################################
=head2 ungrade()

=over 4

=item Description
Move forecasts to ungraded directory

=item Params
none

=item Returns
none

=back

=cut

sub ungrade {
    my ($self) = @_;

    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $file (@files) {
        rename("$self->{'Graded Dir'}/$file","$self->{'Ungraded Dir'}/$file");
    }
}

#########################################
=head2 get_forecasts($dir)

=over 4

=item Description
Get the forecasts in the given directory

=item Params
$dir: path of graded or ungraded directory

=item Returns
list of files

=back

=cut

sub get_forecasts {
    my ($dir,$asn_name) = @_;
    my $e_asn_name = CGI::escape($asn_name);

    $dir =~ /^(\/[^\/]*)(\/[^\/]*)(\/[^\/]*)/;
    if (-e "$1$2$3/assignments/$e_asn_name/archive.dat") {
        if (-e "$dir/$e_asn_name") {
            @files = ($e_asn_name);
        } else {
            @files = ();
        }
    } else {
        opendir(FORECASTS,$dir);
        @files = grep(/^\d{2}\w{3}\d{4}$/,readdir(FORECASTS));
        close FORECASTS;
    }
    return @files;
}

#########################################
=head2 grade_forecasts($dir)

=over 4

=item Description
Grade forecasts in the given directory

=item Params
none

=item Returns
none

=back

=cut

sub grade_forecasts {
    my ($self,$dir) = @_;
    my $fname;
    my @files = get_forecasts($dir,$self->{'Name'});
    foreach $fname (@files) {
        $self->{'Student File'} = $fname;
        $self->grade();
    }
}

#########################################
=head2 regrade()

=over 4

=item Description
Regrade all forecasts for this student

=item Params
none

=item Returns
none

=back

=cut

sub regrade {
    my ($self) = @_;
    $self->grade_forecasts($self->{'Graded Dir'});
    $self->grade_forecasts($self->{'Ungraded Dir'});
}

#########################################
=head2 grade_ungraded()

=over 4

=item Description
Try to grade ungraded assignments

=item Params
none

=item Returns
none

=back

=cut

sub grade_ungraded {
   my ($self) = @_;
   my $dir = $self->{'Ungraded Dir'};
   $self->grade_forecasts($dir,$self->{'Name'});
}

sub get_site {
    my ($self) = @_;
    my $status = $self->get_status();
    $fname = '';
    if ($status) {
        $fname = ($status eq 'graded')? 
            $self->{'Graded Dir'}: $self->{'Ungraded Dir'};
        $fname .= "/$self->{'Student File'}";
    } else {
        return;
    }
    $/ = "\n";
    my $site = '';
    open(WEATHER,"<$fname") or return;
    while(<WEATHER>) {
       # this will handle both BLANK(1.1.1) and OPTION/LIST(1.1) questions
       if (/NAME="1.1/) {
           $site = CN_UTILS::remove_spaces(<WEATHER>);
           last;
       }
    }
    close WEATHER;
    return "\U$site";
}


sub get_runtime_values {
    my ($self) = @_;
    (defined $self->{'Runtime Values'}) and
        return %{$self->{'Runtime Values'}};
    my $fname = $self->get_wx_filename();
    if ($fname =~ /^\d{4}\d{2}\d{2}$/) {
        $site = $self->get_site();
        # check to see if it is in cache
        $cachename = "$CACHE/$site.$fname";
        $rawfile = "$RAWDIR/$fname.out";
    } else {
        $cachename = "$CACHE/$fname";
        $rawfile = "$RAWDIR/$fname.out";
    }
    my %values = {};
    $/ = "\n";
    # use the cache file if there is no raw datafile or the date of
    # the cache is more recent than the rawfile
    if (-e $cachename && (!(-e $rawfile) || (-M $cachename) <= (-M $rawfile))) {
        open(WEATHER,"<$cachename");
        flock(WEATHER,$LOCK_EX);
        while (<WEATHER>) {
            chop;
            ($key,$data) = split('=');
            $values{$key} = $data;
        }
        flock(WEATHER,$LOCK_UN);
        close WEATHER;
    } else {
        # if not in cache then look for raw data file and just return
        # if not present. otherwise, create cache file.
        if (!(-e $rawfile)) { return; };
        open(RAW,"<$rawfile") or return;
        open(WEATHER,">$cachename");
        flock(WEATHER,$LOCK_EX);
        my $store = 0;
        while (<RAW>) {
            chop;
            ($key,$data) = split('=');
            if ($key eq 'STATION') {
                $data = "\U$data";
                $store = ($data =~ $site)? 1: 0;
            }
            if ($store) {
                $values{$key} = $data;
                print WEATHER "$key=$data\n";
            }
        }
        flock(WEATHER,$LOCK_UN);
        close WEATHER;
        close RAW;
        clear_cache();
    }
    $self->{'Runtime Values'} = \%values;
    return %values;
}

sub clear_cache {
   # get file names
   opendir(CF,$CACHE);
   my @files = grep(/^\w{4}\.\d{2}\w{3}\d{4}/,readdir(CF));
   close CF;
   # delete files older than 30 days
   foreach $fname (@files) {
      if ((-W "$CACHE/$fname") > 30) {
          unlink "$CACHE/$fname";
      }
   }
}

sub write_assign_query {
   my ($self) = @_;
   my $query = $self->{'Query'};
   # see if it is stored in option or list
   my $site = CN_UTILS::remove_spaces($query->param('1.1'));
   if ($site eq '') {
       # assume it is a text field and search for station code in database file
       $site = CN_UTILS::remove_spaces($query->param('1.1.1'));
   }
   my $found = 0;
   $/ = "\n";
   open(SITES,"<$SITE");
   while(<SITES>) {
     chop;
     if (/^$site$/i) {
        $found = 1;
	break;
     }
   }
   close(SITES);
   # verify site selection and call parent
   if (!$found) {
       ERROR::print_error_header("Station Code?");
       print "<B>'$site'</B> is not a valid 4 letter site code. <BR>Click on
Back and enter a correct station code.\n";
       CN_UTILS::print_cn_footer();
       exit(0);
   }
   TEST::write_assign_query($self);
}

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

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $escaped_stud_name = CGI::escape($stud_name);

   my $tp = 0;
   my $pr = 0;
   my $text = "<B>Forecasts</B>\n<UL>\n"; 
   # Set input record separator and read the file
   $/ = "\n";

   # get all graded forecasts
   my $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/graded";
   my @files = get_forecasts($path,$asn_name);

   foreach $fname (@files) {
       my $date = CN_UTILS::getTime("$path/$fname");
       open(ASN,"<$path/$fname");
       flock(ASN,$LOCK_EX);
       my $test_header = <ASN>;
       flock(ASN,$LOCK_UN);
       close(ASN);
       my %score = TEST::unpack_stud_test_header($test_header,$fname);
       (defined %score) or
            ERROR::system_error('FORECAST','get_score','unpack sheader',
                                "$fname:$test_header");
       $text .= "<LI><B>$fname:</B> $score{'PR'}/$score{'TP'}";
       my $seen = $scores{'SEEN'};
       if (defined $seen) {
          $text .= "<BR>First Seen on $seen";
       }
       my $subdate = $scores{'SUBDATE'};
       if (defined $subdate) {
          $text .= "<BR>Submitted on $subdate";
       }
       my $date = CN_UTILS::getTime($path);
       $text .= "<BR>Graded on $date<BR>";
       $pr += $score{'PR'}; $tp += $score{'TP'};
   }
   # get all ungraded forecasts
   $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/ungraded";
   my @files = get_forecasts($path,$asn_name);
   foreach $fname (@files) {
       my $date = CN_UTILS::getTime("$path/$fname");
       open(ASN,"<$path/$fname");
       my $adata = <ASN>;
       close(ASN);
       $adata =~ m/<CN_ASSIGN.*\sPTS="?(\d+)\/(\d+)/i;
       $text .= "<LI><B>$fname:</B> ?/$2 ";
       if ($adata =~ /SUBMIT=0/) {
           $text .= "(seen on $date but not submitted)<BR>";
       } else {
           $text .= "(submitted on $date but not yet graded)<BR>";
       }
   }
   $text .= "</UL>\n";
   return ($text,$tp,$pr);
}

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

sub get_names {
    my ($self,$status) = @_;
    my @gfiles = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    my @ufiles = get_forecasts($self->{'Ungraded Dir'},$self->{'Name'});
    push(@gfiles,@ufiles);
    ($status eq 'existing')? @gfiles : ();
}

sub get_stats {
    my ($self,$stats,$tot) = @_;
    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $fname (@files) {
        $self->{'Student File'} = $fname;
        TEST::get_stats($self,$stats,$tot);
    }
}

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = '';
    my $name = $self->{'Name'};
    my @files = get_forecasts($self->{'Graded Dir'},$self->{'Name'});
    foreach $fname (@files) {
        $self->{'Student File'} = $fname;
        $body .= TEST::format_raw_data($self,"$sname\t$fname");
    }
    $body;
}

sub get_extra_fields {
    my ($self) = @_;
    my $fname = "$self->{'Dev Root'}/archive.dat"; 
    if (-e "$fname") {
        open(WEATHER,"<$fname");
        $data = <WEATHER>;
        close WEATHER;
    } else {
        $data = '';
    }       
    return "<H3>Archived Data</H3><TEXTAREA NAME=data ROWS=10 COLS=60>$data</TEXTAREA><HR>";
}

#########################################
=head2 put_extra_fields($query)

=over 4

=item Description
Write the header to the file using %params

=item Params
$query: query form

=item Returns
none

=back

=cut

sub put_extra_fields {
    my ($self,$query) = @_;
    my $fname = "$self->{'Dev Root'}/archive.dat"; 
    $data = CN_UTILS::remove_spaces($query->param('data'));
    if ($data eq '') {
        unlink($fname);
    } else {
        open(WEATHER,">$fname");
        print WEATHER $data;
        close WEATHER;
    }
}
1;
