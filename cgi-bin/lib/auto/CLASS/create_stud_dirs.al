# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub create_stud_dirs {

   my ($self, $disk_uname) = @_;

   my $stud_root_dir = "$self->{'Root Dir'}/students/$disk_uname";
   my $uname = CGI::unescape($disk_uname);
   mkdir($stud_root_dir,0700) or
      ERROR::system_error("CLASS","create_stud_dirs","mkdir root",$stud_root_dir);
   chdir($stud_root_dir);
   (mkdir('graded',0700) and 
    mkdir('ungraded',0700) and
    mkdir('dialog',0700) and
    mkdir('java',0700)) or
      ERROR::system_error(CLASS,"create_stud_dirs","mkdir graded",$stud_root_dir);
}

1;
