# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub check_limit {
   # Has the maximum number of classes been reached? 
   opendir(CLASS_DIR,$GLOBALS::CLASSNET_ROOT_DIR);  
   # Don't include . or .. directories
   my $num_classes = grep(!/^\.\.?$/, readdir(CLASS_DIR));
   closedir(CLASS_DIR);
   if ($num_classes >= $GLOBALS::MAX_CLASS) {
      ERROR::user_error($ERROR::CLASSLIMIT,$GLOBALS::MAX_CLASS);
   }
}

1;
