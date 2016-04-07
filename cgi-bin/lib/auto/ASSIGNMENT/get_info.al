# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub get_info {
    my ($cls,$asn_name) = @_;

   $disk_name = CN_UTILS::get_disk_name($asn_name);
   $root = "$cls->{'Root Dir'}/assignments/$disk_name/options";
   # if the assignment is published, it will be in the main assignment dir
   # if it is not published, it will be in the assignments/.develop dir
   if (!(-e $root)) {
       $root = "$cls->{'Root Dir'}/assignments/.develop/$disk_name/options";
   }
   if (-e $root) {
       $/ = "\n";
       open(ASN,"<$root") or
            ERROR::system_error('ASSIGNMENT','get_info','open',$root);
       my $header = <ASN>;
       close ASN;
       return ASSIGNMENT->unpack_assign_header($header);
   } else {
       return '';
   }
}

1;
