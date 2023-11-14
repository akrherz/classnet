# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub print_base_header {
   my ($self,$window) = @_;
   (!defined $window) and $window = '_top';
   my $base = "$GLOBALS::SECURE_ROOT\/$GLOBALS::SRM_ALIAS$self->{'Dev Root'}\/";
   $base =~ s/\/local1\/classnet//;
   $base =~ s/%/%25/g;
print <<"HEADER";
Content-type: text/html
Window-target: $window

<HTML>
<HEAD>
<TITLE>$self->{'Name'}</TITLE>
<base href="/">
</HEAD>
<BODY $GLOBALS::BGCOLOR>
<CENTER><H3>$self->{'Name'}</H3></CENTER>
HEADER
}

1;
