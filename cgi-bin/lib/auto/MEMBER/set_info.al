# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

sub set_info {
   my ($self,$cls) = @_;
   my (@mem_list,$line_info);

   # Get the member type
   my $mem_type = $cls->mem_exists($self->{'Disk Username'});
   unless ($mem_type) {
       ERROR::user_error($ERROR::MEMBERNF,$self->{'Username'});
   }

   # Open the file
   my $fname = "$self->{'Root Dir'}/admin/members/${mem_type}s/$self->{'Disk Username'}";

   $/ = "\n";
   (open(MEM_FILE, "<$fname")) or
       ERROR::system_error("MEMBER","set_info","Open",$self->{'Username'});
   chomp(@mem_list = <MEM_FILE>);
   close(MEM_FILE);
   foreach $line_info (@mem_list) {
       my ($info_name,$info_value) = split(/=/,$line_info);
       $self->{$info_name} = $info_value;
   }
}

1;
