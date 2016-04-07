# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub archive {
  my ($name) = @_;
  my $self = CLASS->new($name);
  my $dname = "$GLOBALS::ARCHIVE_ROOT_DIR/classes";
  system("cp -r $self->{'Root Dir'} $dname") and
    ERROR::system_error("CLASS","archive","copy","$name:$!");
  system("rm -r $self->{'Root Dir'}") and
    ERROR::system_error("CLASS","archive","rm -r","$name:$!");
  remove_from_classlist($name);
}

1;
