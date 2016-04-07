# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub remove_from_classlist {
   my ($name) = @_;
   my @class_list = list();

   for ($i = 0; ( ($i < @class_list) and ($name ne $class_list[$i]) ); $i++) {}
   if ($i < @class_list) {
       splice(@class_list,$i,1);   
       open(CLASS_LIST, ">$GLOBALS::CLASSNET_ROOT_DIR/class_list") or 
       	   &ERROR::system_error("CLASS","remove_from_class_list","Open",$mem_type);
       $, = "\n";
       print CLASS_LIST @class_list;
       print CLASS_LIST "\n";
       close(CLASS_LIST);
       chmod 0700, "$GLOBALS::CLASSNET_ROOT_DIR/class_list";
   }
}

1;
