# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

sub delete {
   my ($self) = @_;
   system "rm -rf $self->{'Dev Root'}";

   #delete student assignments
   my $cls = $self->{'Class'};
   my @stu_names = $cls->get_mem_names(student);
   foreach $stu (@stu_names) {
      my $disk_name = CGI::escape($stu);
      system "rm -rf $cls->{'Root Dir'}/students/$disk_name/java/$self->{'Disk Name'}";
   }

}

1;
