# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub get_assign_header {
    my ($self) = @_;
    my (%params, $adata);

    # Set input record separator and read the file
    $/ = "\n";

    $fname = "$self->{'Dev Root'}/options";
    open(ASN,"<$fname") or
        ERROR::system_error('ASSIGNMENT','read','open',$fname);
    $adata = <ASN>;
    close(ASN);
    return $adata;    
}

1;
