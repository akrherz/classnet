#!/usr/bin/perl
package FORUM;
require ERROR;

sub new {
   my ($fname,$fowner,$femail) = @_;
   require "$GLOBALS::FORUM_DIR/lib/cgi-lib.pl"; 
   require "$GLOBALS::FORUM_DIR/lib/sys_config";
   require "$GLOBALS::FORUM_DIR/lib/main";
   require "$GLOBALS::FORUM_DIR/lib/forum_config";
   require "$GLOBALS::FORUM_DIR/lib/variables";
   require "$GLOBALS::FORUM_DIR/lib/utilities";
   require "$GLOBALS::FORUM_DIR/admin/cnet_admin.pl";

   # All forums owned by ClassNet Instructor
   $in{'id'} = crypt('cnet',$salt);
   $in{'forum_name'} = $fname;
   $in{'code'} = CN_UTILS::get_disk_name($fname);
   $in{'forum_owner_code_name'} = 'cnet';
   $in{'owner_code_name'} = 'cnet';
   $in{'owner_page'} = "";
   $in{'contact'} = $fowner;
   $in{'contact_email'} = $femail;
   $in{'contact_page'} = "";
   $in{'anyone_add'} = "yes";
   $in{'anyone_add_username'} = "";
   $in{'anyone_add_password'} = "";
   $in{'anyone_add_password2'} = "";
   $in{'description'} = "$fname Discussion";
   $in{'guidelines'} = "<ul>
<li> Topics can be created by anyone.
<li> Anyone can leave messages on any topic.
<li> Please keep topic names as short as possible. You may enter additional
comments when you create a new topic.
</ul>";
   $in{'group'} = "";

   # Add instructor to user list file

   #Start a new forum
   &start_forum;

}

sub edit_discussion {
   my($query) = @_;
   require "$GLOBALS::FORUM_DIR/lib/cgi-lib.pl"; 
   require "$GLOBALS::FORUM_DIR/lib/sys_config";
   require "$GLOBALS::FORUM_DIR/lib/main";
   require "$GLOBALS::FORUM_DIR/lib/forum_config";
   require "$GLOBALS::FORUM_DIR/lib/variables";
   require "$GLOBALS::FORUM_DIR/lib/utilities";
   require "$GLOBALS::FORUM_DIR/admin/cnet_admin.pl";

   $in{'id'} = crypt('cnet',$salt);
   $in{'owner_code_name'} = 'cnet';

   #convert - to %2D and %20 to - for netforum2
   $in{'forum_name'} = $query->{'Class Name'}->[0];
   $in{'forum_code'} = CN_UTILS::get_disk_name($in{'forum_name'});
   $in{'forum_code'} =~ s/\-/\%2D/g;
   $in{'forum_code'} =~ s/\%20/-/g;
   $in{'forum_owner'} = 'ClassNet Instructor';
   $in{'owner_code'} = 'cnet';
   $netforum_url = "$base_url/admin/admin";

   # Save instructor info in file to allow immediate navigation 
   # back to initial netforum page. Alleviates necessity to go back
   # in the browser or to hit "Edit Discussion" again.
   open(NAV_INFO, ">$GLOBALS::FORUM_DIR/$in{'forum_code'}/cnet_navigation_info") or 
       &ERROR::system_error("FORUM","edit_discussion","open","saving instructor info");
   print NAV_INFO "Class Name=$query->{'Class Name'}->[0]\nUsername=$query->{'Username'}->[0]\n";
   print NAV_INFO "Password=$query->{'Password'}->[0]\ncn_option=$query->{'cn_option'}->[0]\n";
   close(NAV_INFO);
   chmod 0700, "$GLOBALS::FORUM_DIR/$in{'forum_code'}/cnet_navigation_info";

   &edit_forum_topics($in{'owner_code_name'},$in{'id'});

}

sub edit {
   my ($fname) = @_;
}

sub archive {
   require ERROR;
   require CN_UTILS;

   my ($fname) = @_;
   $fname = CN_UTILS::get_disk_name($fname);
   #convert - to %2D and %20 to - for netforum2
   $fname =~ s/\-/\%2D/g;
   $fname =~ s/\%20/-/g;

   my $dname = "$GLOBALS::ARCHIVE_ROOT_DIR/forums";
   system("cp -r $GLOBALS::FORUM_DIR/$fname $dname") and
       ERROR::system_error(FORUM,"archive","cp -r","$GLOBALS::FORUM_DIR/$fname:$!");
   system("rm -r $GLOBALS::FORUM_DIR/$fname") and	
       ERROR::system_error(FORUM,"archive","rm -r","$GLOBALS::FORUM_DIR/$fname:$!");

   # Must remove line from netforum2/admin/forumlist
   my $forum_file = "$GLOBALS::FORUM_DIR/admin/forumlist";
   # Get list of forum lines
   open(FORUM_LIST, "<$forum_file") or 
       &ERROR::system_error("FORUM","archive","first Open",$forum_file);
   my @forum_list = <FORUM_LIST>;
   close(FORUM_LIST);
   chomp @forum_list;

   my $i;
   for ($i = 0; $i < @forum_list; $i++) {
       ($cur_class_name) = split(/:/,$forum_list[$i]);   
       ($fname eq $cur_class_name) and
       	   last;
   }
   if ($i == @forum_list) {
       ERROR::system_error("FORUM","archive","for loop","$fname not found in $forum_file");
   }
   else {
       splice(@forum_list,$i,1);   
   }
   
   open(FORUM_LIST, ">$forum_file") or 
       	   ERROR::system_error("FORUM","archive","Second Open",$forum_file);
   $, = "\n";
   print FORUM_LIST @forum_list;
   print FORUM_LIST "\n";
   close(FORUM_LIST);
   chmod 0700, $forum_file;
}

1;







