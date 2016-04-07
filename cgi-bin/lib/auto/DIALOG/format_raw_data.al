# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub format_raw_data {

   my ($self,$sname) = @_;
   undef $/;

   open(ASN,"<$self->{'Dialog Dir'}/$self->{'Disk Name'}");
   my $data = <ASN>;
   close ASN;
   "\n*****$sname ($self->{'Name'}) *****\n$data\n";

}

1;
1;
