# NOTE: Derived from lib/DIALOG.pm.  Changes made here will be lost.
package DIALOG;

sub upload {
   my ($self,$hfile) = @_;


   $self->create();

   # There should probably be MORE error checking here on the incoming form!!

   # Get rid of any form stuff
   $hfile =~ s/<\s*\/?FORM[^>]*>//ig;
   my @ta_array = split(/(<\/textarea>)/i, $hfile);

   # Give names (CN_1, CN_2...) to all textareas. Overide any user names.
   my $num_ta = 0;
   foreach $elt (@ta_array) {
      if (!($elt =~ /<\/textarea>/i)) {
      	 $num_ta++;
      	 $elt =~ s/(<\s*textarea)\s+name=\S+([^>*])/$1$2/i;      	 
      	 $elt =~ s/(<\s*textarea)/$1 name=CN_$num_ta/i;
      }      	 
   }
   if ($hfile =~ m/href="?^h/i) {
        ERROR::user_error($ERROR::NOTDONE,
      	    "All hrefs must be <b>href=\"http://.....</b>");
        exit(0);
   }
 
   # Just give the assignment file the assignment name
   my $file = "$self->{'Dev Root'}/$self->{'Disk Name'}";
   open(DIALOG_FILE,">$file") or
       ERROR::system_error('Dialog.pm',"upload","open",$self->{'Name'});
   print DIALOG_FILE @ta_array;
   close DIALOG_FILE;
   chmod 0600, $file;
   
   return;
}

1;
