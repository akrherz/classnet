# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub pack_question_header {
    my (%params) = @_;
    my $hdr = '<CN_Q ';
    $hdr .= "TYPE=$params{'Question Type'} ";
    ($params{'ANS'}) 
        and $hdr .= "ANS=\"$params{'ANS'}\" ";
    ($params{'JUDGE'}) 
        and $hdr .= "JUDGE=$params{'JUDGE'} ";
    ($params{'ROWS'}) 
        and $hdr .= "ROWS=$params{'ROWS'} ";
    ($params{'COLS'}) 
        and $hdr .= "COLS=$params{'COLS'} ";
    ($params{'N'}) 
        and $hdr .= "N=$params{'N'} ";
    return $hdr . '>';
}

1;
