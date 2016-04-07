# NOTE: Derived from lib/JAVA.pm.  Changes made here will be lost.
package JAVA;

sub upload {
   my ($self,$hfile) = @_;

   if ( !(-e $self->{'Dev Root'}) ) {
      $self->create();
   }

   # Name of file is last
   my @toks = split('/',$url);
   my $file = "$self->{'Dev Root'}/$toks[$#toks]";
   open(JAVA_FILE,">$file") or
       ERROR::system_error('Java.pm',"upload","open",$file);
   print JAVA_FILE $hfile;
   close JAVA_FILE;
   chmod 0600, $file;
   
   return;
}
1;
