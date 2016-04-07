# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub put_assign_header {
    my ($self,$hdr) = @_;
    $fname = "$self->{'Dev Root'}/options";
    open(ASN,">$fname") or
        ERROR::system_error('ASSIGNMENT','put_assign_header','open',$fname);
    print ASN "$hdr\n";
    close(ASN);
}

1;
