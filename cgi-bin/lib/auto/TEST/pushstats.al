# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub pushstats {
    my ($slist,$prefix,$cats,$stats) = @_;
    my @catlist = @{$cats};
    if ($#catlist >= 0) {
       my $catname = shift(@catlist);
       foreach $key (keys %{$stats}){
           pushstats($slist,"$prefix <TR><TD>$catname</TD><TD>$key</TD></TR>",\@catlist,$stats->{$key});
       }
    } else {
       push(@{$slist},$prefix,$stats);

    }
}

1;
