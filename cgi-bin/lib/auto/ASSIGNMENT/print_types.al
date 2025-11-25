# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub print_types {
    my $class = shift;
    # Handle both method and legacy calls
    my $name = ref($class) ? $class : shift;
    @types = split(/,/,$GLOBALS::ASSIGNMENT_TYPES);
    print "<SELECT NAME=\"Assignment Type\">\n";
    foreach (sort @types) {
        print '<OPTION ';
        if ($_ eq $name) {
           print "<OPTION SELECTED>$_\n";
        } else {
           print "<OPTION>$_\n";;
        }
    }
    print "</SELECT>\n";
}

1;
