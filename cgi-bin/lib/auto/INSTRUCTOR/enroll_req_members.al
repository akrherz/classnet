# NOTE: Derived from lib/INSTRUCTOR.pm.  Changes made here will be lost.
package INSTRUCTOR;

#########################################

sub enroll_req_members {
   my ($self, $query, $cls) = @_;
   my ($mem, $num_deletes, $num_adds, @add_list);

   # Set up the directories
   my $stud_dir_root = $self->{'Root Dir'} . "/admin/members/students";
   my $req_dir_root = $self->{'Root Dir'} . "/admin/members/requests";

   # Loop through the list of additions and enroll those students
   # The student usernames are already escaped
   my @enroll_list = $query->param();
   my $txt = "";
   $num_adds = 0; $num_dels = 0;
   foreach $mem (@enroll_list) {
       if ($mem =~ /^STU_/) {
           my $op = $query->param($mem);
           $mem = substr($mem,4);
           my $disk_uname = CGI::unescape($mem);
           $disk_uname = CN_UTILS::get_disk_name($disk_uname);
           if ($op eq 'app') {
               my $req_file = "$req_dir_root/$disk_uname";
               my $stud_file = "$stud_dir_root/$disk_uname";
               if (!(-e $stud_file) and (-e $req_file)) {
       	           rename ($req_file, $stud_file);
       	           $cls->create_stud_dirs($disk_uname);
       	           push (@add_list, $mem);
                   push (@del_list, $disk_uname);
                   $num_adds++;
       	           $txt .= "Username $mem was added.\n";
                   my %info = $cls->get_mem_info($mem);
                   CN_UTILS::mail($info{'Email Address'},"Username $mem approved",
                       "Username '$mem' is ready for use in ClassNet class $cls->{'Name'}.");
               }
               elsif (-e $stud_file) {
       	           $txt .= "Username $mem is already enrolled.\n";
               }
               else {
       	           $txt .= "Username $mem is not on the request list.\n";
               }
            } elsif ($op eq "rej") {
                push(@del_list,$disk_uname);
                $num_dels++;
            }
        }
    }

   $cls->add_to_mem_list('student', @add_list);
    # Remove the rejected requests
   chdir($req_dir_root);
   unlink @del_list;
   $txt .= "\nStudents added: $num_adds\nRequests rejected: $num_dels\n";
   CN_UTILS::mail($self->{'Email Address'},"Enrollment Update for $cls->{'Name'}",$txt);
    $cls->member_menu($self);
    exit(0);
}

1;
