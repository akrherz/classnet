# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub list {
    my $class = shift; # Handle method call - ignore class arg
          
open(CLASS_LIST, "<$GLOBALS::CLASSNET_ROOT_DIR/class_list") or
    &ERROR::system_error("CLASS","list","open",
                         "$GLOBALS::CLASSNET_ROOT_DIR/class_list");
    my @list = <CLASS_LIST>;
    chop @list;
    close CLASS_LIST;
    return @list;
}

1;
