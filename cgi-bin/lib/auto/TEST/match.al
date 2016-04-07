# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub match {
    my ($self,$key_ans,$stud_ans,$judge_str) = @_;

    # Need a default?
    $judge_str or $judge_str = 'EXACT';
    my $num = ($judge_str =~ /NUM/);
    my $exact = (($judge_str =~ /EXACT/) and !($judge_str =~ /NOEXACT/));
    my $spell = (($judge_str =~ /SPELL/) and !($judge_str =~ /NOSPELL/));
    my $punc = (($judge_str =~ /PUNC/) and !($judge_str =~ /NOPUNC/));
    my $ord = (($judge_str =~ /ORD/) and !($judge_str =~ /NOORD/));
    my $cnt = (($judge_str =~ /CNT/) and !($judge_str =~ /NOCNT/));
    my $caps = (($judge_str =~ /CAPS/) and !($judge_str =~ /NOCAPS/));

###########################################################
####PATCH: Change when all judge options programmed########
####Only exact and numeric judging#########################
###########################################################  
    # substitute {name} in answer with run-time values
    my %values = $self->get_runtime_values();
    (defined %values) and $key_ans =~ s/{\s*(\w+)\s*}/$values{$1}/g;
    # replace any remaining dynamic values with blank.
    $key_ans =~ s/{\s*(\w+)\s*}//g;
    $key_ans = CN_UTILS::remove_spaces($key_ans);
    # if key_ans is blank then assume student answer is correct
    ($key_ans eq '') and return 1;
    # change escaped | with ascii value
    $key_ans =~ s/\\\|/\%7C/g;

    foreach $ans (split(/\|/,$key_ans)) {
        # restore |
        $ans =~ s/\%7C/\|/g;
        if ($num) {
           # Remove any commas
           $ans =~ s/,//g;
           $stud_ans =~ s/,//g;
           if ($ans =~ m/"?([+|-]?\d+\.?\d*):([+|-]?\d+\.?\d*)/ ) {
       	       my $low = $1 - 0.000001;
       	       my $high = $2 + 0.000001;
       	       (($stud_ans >= $low) and ($stud_ans <= $high)) and return 1;
           }
           else { 
       	       ($ans =~ m/"?([+|-]?\d+\.?\d*)/);
       	       my $diff = abs ($stud_ans - $1);
       	       ($diff <= .000001) and return 1;
           }
        } else {
           if ($caps != 1) {
               $ans = "\U$ans\E";
               $stud_ans = "\U$stud_ans\E";
           }
           if ($punc != 1) {
               $ans =~ s/[!-\/:-@\[-`\{-~]/ /g;
               $stud_ans =~ s/[!-\/:-@\[-`\{-~]/ /g;
           }
           if ($exact != 1) {
              # remove multiple spaces
              $ans =~ s/\s{2}/ /g;
              # remove leading and trailing spaces
              $ans =~ s/^\s+|\s+$//g;
              # remove multiple spaces
              $stud_ans =~ s/\s{2}/ /g;
              # remove leading and trailing spaces
              $stud_ans =~ s/^\s+|\s+$//g;
           }
           ($ans eq $stud_ans) and return 1;
        }
    }
    return 0;
    #return JUDGE::judge($key_ans,$stud_ans,$spell,$punc,$ord,$cnt);
}

1;
