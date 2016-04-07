# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub delete {
   my ($self) = @_;
   system "rm -rf $self->{'Dev Root'}";

   #delete student assignments
   my $cls = $self->{'Class'};
   my @stu_names = $cls->get_mem_names(student);
   foreach $stu (@stu_names) {
      my $disk_name = CGI::escape($stu);
      system "rm -f $cls->{'Root Dir'}/students/$disk_name/dialog/$self->{'Disk Name'}";
      system "rm -f $cls->{'Root Dir'}/students/$disk_name/dialog/$self->{'Disk Name'}.cn_bak*";
   }

}

1;
