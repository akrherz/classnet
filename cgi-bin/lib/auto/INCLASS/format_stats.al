# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub format_stats {
    my ($self,$stats,$tot) = @_;
    my $fname = "$$.dat";
    open(DATA,">$fname");
    my $max = 0;
    foreach $v (keys %{$tot}) {
        my $n = $tot->{$v}; 
        print DATA "$v $n\n";
        ($n > $max) and $max = $n;
    }
    close(DATA);
    my $tp = $self->{'TP'};
    TEST->print_test_header("Statistics");
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
HEAD
    CN_UTILS::print_cn_footer();
}

1;
