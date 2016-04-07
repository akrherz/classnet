# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub format_stats {
    my ($self,$st,$tot) = @_;
    $self->read_key();
    my $key = $self->{'Key'};
    my $form = '<FORM>';
    my $question;
    # Read all blocks and questions
    !($self->{'bl_q'}) and
        $self->read_all();
    my $bl_q = $self->{'bl_q'};
    my %values = $self->get_runtime_values();
    my $nb = $self->block_count();
    my @slist = ();
    my @clist = split(/,/,$self->{'Categories'});
    pushstats(\@slist,"",\@clist,$st);
    for ($i = 0; $i <= 2 * $#slist; $i++) {
       my $label = shift(@slist);
       my $stats = shift(@slist);
       if ($label ne '') {
           $form .= "<TABLE ALIGN=CENTER BGCOLOR=#CCCCCC BORDER=1><TR><TH>Question</TH><TH>Answer</TH></TR>$label</TABLE>";
       }
       for ($b = 1; $b <= $nb; $b++) {
           $form .= $self->check_java("$bl_q->{$b}{'btext'}","play");
           my $nq = $self->question_count($b);
           for ($q = 1; $q <= $nq; $q++) {
               my $row1 = '<TH ALIGN=CENTER>Answer</TH>';
               my $row2 = '<TD ALIGN=CENTER>Count</TD>';
               my $root = "$b.$q";
               $ans = $key->{$root}{'ANS'};
               my $key_ans = $bl_q->{$root}{'ANS'};
               if (defined %values) {
                   $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/eg;
               }

    	       #set up blank and multiple key answers for replace_placeholders
    	       #***NOTE!! This assumes that any runtime values have been previously escaped properly!!***
               if ( ($key->{$root}{'Question Type'} =~ /BLANK/i)
    	    	     or($key->{$root}{'Question Type'} =~ /MULTIPLE/i) )   {
       	    	   my @key_answers = split(/,/, $key_ans);
       	    	   grep {s/%22/"/g; s/%2C/,/g} @key_answers;
    	    	   $key_ans = join("%2C",@key_answers);
    	       }
    	    
               if ($key->{$root}{'Question Type'} =~ /ESSAY/i) {
    	    	   #$question = $self->replace_placeholders($stats->{$root},$b,$q,%{$bl_q->{$root}});
                   $question = $stats->{$root};
               }
    	       else {
    	    	   $question = $self->replace_placeholders($key_ans,$b,$q, 
                                                       %{$bl_q->{$root}});
    	       }
               if ($key->{$root}{'Question Type'} =~ /BLANK/i) {
                   $n = $key->{$root}{'N'};
                   for ($i = 1; $i <= $n; $i++) {
                       my $blnk = "$root.$i";
                       if (defined $stats->{$blnk}) {
                           foreach $ans (keys %{$stats->{$blnk}}) {
                               $row1 .= "<TH ALIGN=CENTER>$ans</TH>\n";
                               $row2 .= "<TD ALIGN=RIGHT>$stats->{$blnk}{$ans}</TD>\n";
                           }
                       }
                   }
               } elsif ($key->{$root}{'Question Type'} =~ /MULTIPLE/i) {
                   $n = $key->{$root}{'N'};
                   for ($i = 1; $i <= $n; $i++) {
                       my $blnk = "$root.$i";
                       my $nm = $stats->{$blnk}{'1'};
                       (! defined $nm) and $nm = 0;             
                       $row1 .= "<TH ALIGN=CENTER>$i</TH>\n";
                       $row2 .= "<TD ALIGN=RIGHT>$nm</TD>\n";
                   }
               } elsif ($key->{$root}{'Question Type'} =~ /ESSAY/i) {
    	    	   $question =~ s/(<textarea)/<br><b>Student Answers:<\/b><br>$1/i;
                   $row1 = "<TH ALIGN=CENTER>Essay</TH>\n";
                   $row2 = "<TD ALIGN=CENTER>N/A</TD>\n";
               } else {
                   if (defined $stats->{$root}) {
                       foreach $ans (keys %{$stats->{$root}}) {            
                           $row1 .= "<TH ALIGN=CENTER>$ans</TH>\n";
                           $row2 .= "<TD ALIGN=RIGHT>$stats->{$root}{$ans}</TD>\n";
                       }
                   }
               }
               $form .= "<B>$b)</B> $question<P><TABLE BORDER=1 BGCOLOR=#FFFFFF>$row1<TR>$row2</TABLE><P>\n";
           }
       }
    }
    $form .= '</FORM>';
    my $fname = "$$.dat";
    open(DATA,">$fname");
    my $max = 0;
    foreach $v (keys %{$tot}) {
        my $n = $tot->{$v}; 
        print DATA "$v $n\n";
        ($n > $max) and $max = $n;
    }
    close(DATA);
    my $tp = $self->{'Key Header'}{'TP'};
    TEST::print_test_header("Statistics");
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
    print <<"HEAD";
<CENTER><H4>$self->{'Name'}</H4>$GLOBALS::HR
<IMG BORDER=2 SRC=$gname>
</CENTER>
$form
HEAD
    CN_UTILS::print_cn_footer();

}

1;
