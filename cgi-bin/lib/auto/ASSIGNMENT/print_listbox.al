# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub print_listbox {
    my ($cls,$which,$mult) = @_;
    opendir(ASNDIR,"$cls->{'Root Dir'}/assignments");
    @asnfiles = grep(!/^\.\.?/,readdir(ASNDIR));
    closedir(ASNDIR);
    $dev_dir = "$cls->{'Root Dir'}/assignments/.develop";
    if (($which eq 'all') && (-e $dev_dir)) {
        opendir(DEVDIR,$dev_dir);
        push(@asnfiles,grep(!/^\.\.?/,readdir(DEVDIR)));
        closedir(DEVDIR);
    }
    foreach $i (0..$#asnfiles) {
       $asnfiles[$i] = CGI::unescape($asnfiles[$i]);
    }
    print "<SELECT $mult SIZE=5 NAME=\"Assignment Name\">\n";
    foreach $assign_name (sort {uc($a) cmp uc($b)} @asnfiles) {
        print qq|<OPTION> $assign_name\n|;
    }
    print "</SELECT>";
}

1;
