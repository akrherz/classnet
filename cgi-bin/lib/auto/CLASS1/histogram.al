# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub histogram {
   my ($self,$stud_names,$asn_names,$inst) = @_;
   my $query = $self->{'Query'};
   my $asn_info = {};

   # produce histogram of scores across assignments
   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   
   # Get an associative array of assignment types
   foreach $asn_name (@{$asn_names}) {
       my $disk_name = CGI::escape($asn_name);
       my %info = ASSIGNMENT->get_info($self,$asn_name);
       $asn_info{$asn_name} = \%info;
   }
   my %tot = {};
   my $tp;
   foreach $stud_name (@{$stud_names}) {
       my $score = 0;
       $tp = 0;
       foreach $asn_name (@{$asn_names}) {
           my $asn_type = $asn_info{$asn_name}{'Assignment Type'};
           my @scores = ($asn_type)->get_score($self,$asn_name,$stud_name);
           my $sc = $scores[2];
           if ($sc =~ /(\?|\*|\-|\#)/) {
             if ($sc =~ /(\d+)\?/) {
                 $sc = $1;
             } else {
                 $sc = 0;
             }
           }
       	   $score += $sc;
           $tp += $scores[1];
       }
       $tot{$score}++;
   }
   my $fname = "$$.dat";
   open(DATA,">$fname");
   my $max = 0;
   foreach $v (keys %tot) {
       my $n = $tot{$v}; 
       print DATA "$v $n\n";
       ($n > $max) and $max = $n;
   }
   close(DATA);
   my @parms = (
'set terminal pbm color small',
'set data style impulse',
'set size .5,.5',
'set boxwidth .1',
'set xlabel "Score"',
'set ylabel "Count"',
'set nolabel',
"set xrange [0:$tp]",
"set yrange [0:$max]",
"set ytics 0,1,$max",
'set format x "%3.0f"',
'set format y "%3.0f"',
'set title "Score Distribution"',
"plot '$fname' title '' with impulse 3");
my $gname = CN_UTILS::plot($fname,\@parms);
unlink $fname;
my $filename = $gname;
$filename =~ /(\d+.gif)/;
$filename = "/local1/www/apache-isu/htdocs/tmpgifs/$1";

   TEST->print_test_header('Histogram');
   print <<"HISTOGRAM";
<CENTER><H4>$self->{'Name'}</H4></CENTER>$GLOBALS::HR
<CENTER><H3>Histogram of Scores</H3>
<IMG BORDER=2 SRC=\"$gname\"></CENTER>
<P>
<CENTER>Click on Publish to make available to students<BR>
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/gradebook>
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">
<INPUT TYPE=hidden NAME=Filename VALUE="$filename">
<INPUT TYPE=hidden NAME=cn_option VALUE="Publish Histogram">
<INPUT TYPE=SUBMIT VALUE="Publish">
</CENTER>
</FORM>
HISTOGRAM
   print "<P>For assignments:<BR>\n<UL>\n";
   foreach $asn_name (@{$asn_names}) {
       print "<LI>$asn_name\n";
   }
   print "</UL>\n";
   if ($file_name ne '') {
       print "<P>This histogram of total class scores is viewable by students.<P>";
   }
   print "</BODY>\n</HTML>\n";
   exit(0);
}

1;
1;
