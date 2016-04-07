# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

sub send_email {
   my ($self, $query, $cls) = @_;
   my @mem_names;
   my $email_recips = "";    	       
   my $SENDMAIL = '/usr/sbin/sendmail';
   my @mem_names = $query->param('All Students') ?
       $cls->get_mem_names('student'):$query->param('Students');
   push (@mem_names, $query->param('All Instructors')?
       $cls->get_mem_names('instructor'):$query->param('Instructors'));

   $n = @mem_names;
   if ($n == 0) {
       ERROR::user_error($ERROR::NOTDONE,"mail message because you didn't select any recipients. Click <B>Back</b> and try again");
   }
   # Get in the email addresses of all members into one string
   my $i = 0;
   my $email_recips = '';    	       
   foreach $mem_name (@mem_names) {
       %mem_info = $cls->get_mem_info($mem_name);
       my $recip_info = ", $mem_info{'Email Address'} ($mem_info{'First Name'} $mem_info{'Last Name'})";
       $email_recips =~ s/$/$recip_info/;
       $i++;
       if (($i % 50) == 0 || $i == $n) {
           open (MAIL, "| $SENDMAIL  -t -n -oi -f $mem_info{'Email Address'}") ||
       	       ERROR::system_error("MEMBER.pm", "send_email", "Open Mail", 
       	           	       	       "From: $self->{'Username'}", "To: $mem_info{'Email Address'}");
           print MAIL "Reply-to: $self->{'Email Address'} ($self->{'First Name'} $self->{'Last Name'})\n";
           print MAIL "From: $self->{'Email Address'} ($self->{'First Name'} $self->{'Last Name'})\n";
           print MAIL "Bcc: $email_recips\n";
           print MAIL "Errors-to: $self->{'Email Address'}\n";
           print MAIL "Subject: $query->{'Subject'}->[0]\n";
           print MAIL "$query->{'Message'}->[0]\n\n";
           close (MAIL);
           $email_recips = '';
        }
   }
   $self->print_menu($cls);
   exit(0);
}

1;
