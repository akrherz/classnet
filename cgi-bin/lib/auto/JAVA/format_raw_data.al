# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

sub format_raw_data {

   my ($self,$sname) = @_;
   my @asnfiles;
   opendir(JAVADIR,$self->{'Java Dir'});
   push(@asnfiles,grep(!/^\.\.?/,readdir(JAVADIR)));
   closedir(JAVADIR);

   undef $/;
   foreach $asn_name (sort {uc($a) cmp uc($b)} @asnfiles) {
      open(ASN,"<$self->{'Java Dir'}/$asn_name");
      my $data = <ASN>;
      $body .= "*****$sname ($asn_name) *****\n$data\n";
   }
   return $body;
}

1;
1;
