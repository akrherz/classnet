# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub create {
    my ($class, $self) = @_;
    # Handle both method and legacy calls
    if (ref($class)) { $self = $class; }
    # if the assignment already exists report error
    if (-e $self->{'Dev Root'}) {
        ERROR::user_error($ERROR::ASSIGNEX,$self->{'Name'}); 
    }
    # create .develop directory if not already there
    $cls = $self->{'Class'};
    $dev_dir = "$cls->{'Root Dir'}/assignments/.develop";
    if (!(-e $dev_dir)) {
        mkdir($dev_dir,0700);
    }
    $asn_dir = $self->{'Dev Root'};
    mkdir($asn_dir,0700) or
        ERROR::system_error('ASSIGNMENT','create','mkdir',$asn_dir);
}

1;
