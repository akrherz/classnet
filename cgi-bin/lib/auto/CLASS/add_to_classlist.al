# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub add_to_classlist {

   my ($name) = @_;
   my @class_names = list();
   push (@class_names, $name);
   open(CLASS_LIST, ">$GLOBALS::CLASSNET_ROOT_DIR/class_list") or 
       &ERROR::system_error("CLASS","create","open","class list");
   $, = "\n";
   print CLASS_LIST sort { uc($a) cmp uc($b)} @class_names;
   print CLASS_LIST "\n";
   close(CLASS_LIST);
   chmod 0700, "$GLOBALS::CLASSNET_ROOT_DIR/class_list";
}

1;
