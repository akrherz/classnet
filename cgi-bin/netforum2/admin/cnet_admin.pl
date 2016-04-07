#!/usr/bin/perl
###ISU Change required files -- IN FORUM.pm: 
#require "ctime.pl";
#require "../lib/sys_config";
#require "../lib/forum_config";
#require "../lib/variables";
#require "../lib/utilities";
#####

sub start_forum{

	$owner_code_name = $in{'owner_code_name'};
	$id = $in{'id'};
	&check_user($owner_code_name, $id);
	&check_toolbar;
# HEY ! these must be localized! or the logic below will fail at times.
	local($forum_name, $forum_code, $forum_owner, $forum_owner_site,
		$forum_monitor, $forum_monitor_email, $anyone_add, $description, 
		$guidelines, $group, $anyone_add_username, $anyone_add_password,
		$anyone_add_password2, $forum_code);
	
    $forum_name = $in{'forum_name'};
    $forum_code = $in{'code'};
    #$forum_owner = $in{'owner'};
    $forum_owner_code_name = $in{'forum_owner_code_name'};
    $forum_owner_site = $in{'owner_page'};
    $forum_monitor = $in{'contact'};
    $forum_monitor_email = $in{'contact_email'};
    $forum_monitor_site = $in{'contact_page'};
    $anyone_add = $in{'anyone_add'};
    $anyone_add_username = $in{'anyone_add_username'};
    $anyone_add_password = $in{'anyone_add_password'};
    $anyone_add_password2 = $in{'anyone_add_password2'};
    $description = $in{'description'};
    $guidelines = $in{'guidelines'};
    $group = $in{'group'};

########Next line is ISU Change#######
    $forum_code =~ s/\-/\%2D/g;
######################################

    $forum_code =~ s/\%20/-/g;


    if ( (!($forum_name)) || 
	 
	 
	 (!($forum_monitor)) ||
	 (!($forum_code)) ||
	 (!($forum_monitor_email)) ) 
	{
		&doh("Required Fields missing - start_forum");
	}
	if(!($forum_owner_code_name)){
		&doh("Forum owner code name missing. $forum_owner_code_name - start_forum");
	}
	if(($forum_name =~ /:/)){
		&doh("Forum name cannot contain \":\" - start_forum");
	}
	if(($forum_owner =~ /:/)){
		&doh("Forum owner name cannot contain \":\" - start_forum");
	}
	if(($forum_owner_code_name =~ /:/)){
		&doh("Forum owner code cannot contain \":\" - start_forum");
	}
	if(($forum_code =~ /:/)){
		&doh("Forum code cannot contain \":\" - start_forum");
	}
	
	# &check_owner_name($forum_owner_code_name);
	
    if ( $anyone_add eq "no" &&
	  (!$anyone_add_username || !$anyone_add_password) )
    {
		&doh("Username and/or password fields missing - start_forum");
    }

    if ( ($anyone_add eq "no") && 
	 ($anyone_add_password ne $anyone_add_password2) ) 
    {
		&doh("Passwords are not the same. - start_forum");
    }

	$forumlist = "$home_directory/admin/forumlist";
	
	$forum_owner = &get_forum_owner($forum_owner_code_name);
	
	if(-e $forumlist)
	{		
		open(FORUM_LIST, $forumlist) || &doh("Cannot open forums file: $forumlist - start_forum");
		&lock(FORUM_LIST);
		while($line = <FORUM_LIST>){
			($code, $name, $owner, $owner_code) = split(/:/, $line);
			$code =~ s/\s//g;
			if($code eq $forum_code)
			{
				&doh("Some one is already using the code: $forum_code - start_forum");	
			}
		}
		close(FORUM_LIST);
		&unlock(FORUM_LIST);
	}

    &decode($guidelines);
    &decode($description);	
	
#   &verify_email_address($forum_monitor_email);
	
    if ($description)
    {
	&check_hot_tamale($description);
    }

    if ($guidelines)
    {
	&check_hot_tamale($guidelines);
    }

#    unless ($anyone_add eq 'yes')
#    {
#	$u = crypt($anyone_add_username,$anyone_add_password);
#	$p = crypt($anyone_add_password,$anyone_add_username);
#    }


    mkdir("$home_directory/$forum_code", "0777") || 
	&doh("Couldn't create directory \"$home_directory/$forum_code\" - start_forum");

    chmod 0777, "$home_directory/$forum_code";

	# HEY - File hierarchy change:
	
    mkdir("$home_directory/$forum_code/topics", "0777") || 
      &doh("Couldn't create directory \"$home_directory/$forum_code/topics\" - start_forum");

    chmod 0777, "$home_directory/$forum_code/topics";

    mkdir("$home_directory/$forum_code/responses", "0777") || 
       &doh("Could not create directory \"$home_directory/$forum_code/responses\" - start_forum");

    chmod 0777, "$home_directory/$forum_code/responses";

	# Create individual files: group, description, and guidelines:

    if ($group)
    {
	$group =~ s/\r/\n/g;
	$group =~ s/\n\n/\n/g;
	$group =~ s/^\s/ /g;
	$group =~ s/ $/ /g;
	#$group =~ s/^\s$//g;    # there were two of these why?
	open(G, ">$home_directory/$forum_code/group") || 
	    &doh("Couldn\'t create file \"$home_directory/$forum_code/lib/group\" - start_forum");
	&lock(G);
	print G ($group);
	close(G);
	&unlock(G);
     }

    if ($description) 
    {
	&decode($description);
	open(DESC, ">$home_directory/$forum_code/description") || 
	    &doh("Couldn\'t create file \"$home_directory/$forum_code/description\" - start_forum");
	    &lock(DESC);
	print DESC ($description);
	close (DESC);
	&unlock(DESC);
    }

    if ($guidelines) 
    {
	&decode($guidelines);
	open(GU, ">$home_directory/$forum_code/guidelines") || 
	    &doh("Couldn\'t create file \"$home_directory/$forum_code/guidelines\" - start_forum");
	&lock(GU);
	print GU ($guidelines);
	close(GU);
	&unlock(GU);
    }
	
	# create forum_config file within forum directory
	$forum_config = "$home_directory/lib/forum_config";
	open(CONFIG, "$forum_config") ||
		&doh("Couldn\'t open file $forum_config - start_forum");
	&lock(CONFIG);
	@config_info = <CONFIG>;
	close(CONFIG);
	&unlock(CONFIG);
	
	$new_config = "$home_directory/$forum_code/forum_config";
	open(NEW_CONFIG, ">$new_config");
	&lock(NEW_CONFIG);
	print NEW_CONFIG (@config_info);
	close(NEW_CONFIG);
	&unlock(NEW_CONFIG);
	
	chmod 0777, "$new_config";
	
	# create header file within forum directory
	$header = "$home_directory/lib/header";
	if(-e $header){
		open(HEADER, "$header") ||
		&doh("Couldn\'t open file $header - start_forum");
		&lock(HEADER);
		@header_info = <HEADER>;
		close(HEADER);
		&unlock(HEADER);
	
		$new_header = "$home_directory/$forum_code/header";
		open(NEW_HEADER, ">$new_header");
		&lock(NEW_HEADER);
		print NEW_HEADER (@header_info);
		close(NEW_HEADER);
		&unlock(NEW_HEADER);
	
		chmod 0777, "$new_header";
	}
	# create footer file within forum directory
	$footer = "$home_directory/lib/footer";
	if(-e $footer){
		open(FOOTER, "$footer") ||
		&doh("Couldn\'t open file $footer - start_forum");
		&lock(FOOTER);
		@footer_info = <FOOTER>;
		close(FOOTER);
		&unlock(FOOTER);
	
		$new_footer = "$home_directory/$forum_code/footer";
		open(NEW_FOOTER, ">$new_footer");
		&lock(NEW_FOOTER);
		print NEW_FOOTER (@footer_info);
		close(NEW_FOOTER);
		&unlock(NEW_FOOTER);
	
		chmod 0777, "$new_header";
	}
	
	# create "a" file:

    $forum_monitor_email =~ s/\@/\\\@/;
    if($cgi_required)
    {
    	$a_path = "$home_directory/$forum_code/a.cgi";
    }
    else
    {
    	$a_path = "$home_directory/$forum_code/a";
    }

########Next 2 lines are ISU Change and in $netforum_url line below#######
    my $esc_forum_code = $forum_code;
    $esc_forum_code =~ s/\%/\%25/g;
##########################################

    open(NEW, ">$a_path") || 
	&doh("Couldn\'t create file \"$a_path\" - start_forum");
	&lock(NEW);
    print NEW "\#\!$perl_path \-si

require \"ctime.pl\";
require \"$home_directory/lib/sys_config\";
require \"$home_directory/lib/forum_config\";
if(\$allow_forum_config){
require \"$home_directory/$forum_code/forum_config\";
}
require \"$home_directory/lib/main\";
require \"$home_directory/lib/variables\";
require \"$home_directory/lib/utilities\";


\$which_forum = \"$forum_code\";\n";

if($cgi_required){
print NEW "\$script_name = \'a.cgi\';\n";
}
else{
print NEW "\$script_name = \'a\';\n";
}


print NEW "\$netforum_url = \"\$base_url/$esc_forum_code/\$script_name\";\n\n"; 

    unless ($anyone_add eq 'yes')
    {
	print NEW ("\$anyone_add = \'$anyone_add\';\n");
	print NEW ("\$anyone_add_username = \'$anyone_add_username\';\n");
	print NEW ("\$anyone_add_password = \'$anyone_add_password\';\n");
    }

    print NEW "\$forum_name = \"$forum_name\";\n";
    print NEW "\$forum_owner = \"$forum_owner\";\n";
    print NEW "\$forum_owner_code_name = \"$forum_owner_code_name\";\n";
    print NEW "\$forum_monitor = \"$forum_monitor\";\n";
    print NEW "\$forum_monitor_email = \"$forum_monitor_email\";\n";


    if ( $forum_owner_site ) {
	print NEW "\$forum_owner_site = \"$forum_owner_site\";\n";
    }   

    if ( $forum_monitor_site ) {
	print NEW "\$forum_monitor_site = \"$forum_monitor_site\";\n";
    }

    print NEW "


if (\$ENV{\'REQUEST_METHOD\'} eq \'GET\') {
	\&get_url_vars;
	\&get_command;
}

if (\$ENV{'REQUEST_METHOD'} eq \'POST\') {
	\&ReadParse();
	\&get_url_vars;
	\&post_command;
}\n\n";

	close(NEW);
	&unlock(NEW);
	if($cgi_required){
		chmod 0777, "$home_directory/$forum_code/a.cgi";
	}
	else{
		chmod 0777, "$home_directory/$forum_code/a";
	}
	
	
	
	open(FORUM_LIST, ">>$forumlist") 
	|| &doh("Cannot open forums file: $forumlist - start_forum");
	&lock(FORUM_LIST);
	print FORUM_LIST ("$forum_code:$forum_name:$forum_owner:$forum_owner_code_name\n");
	close(FORUM_LIST);
	&unlock(FORUM_LIST);
	
# HEY! update netforum page here.
###ISU chage###
#    unless( $httpheader ) { print &http_header; }
#    print "<Title>Forum: $forum_name -  Created</TITLE>\n";
#    &header;
#    print "<h3>NetForum Administration : Create Forum</h3>";
#    print "<H2>Forum: $forum_name Created</H2>";
    
#	print "<HR>";
#    &admin_footer($owner_code_name, $id);
#    print "<HR>";
#    print "The URL for the new forum is: "; 
#    if($cgi_required){
#    print "<A HREF = \"$url/$base_url/$forum_code/a.cgi/$show_topics_command\">";
#    print "$url/$base_url/$forum_code/a.cgi/$show_topics_command</a><BR>\n";
#    }
#    else{
#    print "<A HREF = \"$url/$base_url/$forum_code/a/$show_topics_command\">";
#    print "$url/$base_url/$forum_code/a/$show_topics_command</a><BR>\n";
#    }
#    print "Please write this URL down for future reference or keep it in your";
#    print " bookmarks so that you can refer to it later. <BR>\n";
#    print "<HR>";
#    
#    &footer;
###########
}

sub check_toolbar {

	local($no_no_button) = @_;
	local($i, @list, $llength);
	
	if($admin_right eq "YES"){
		@list = ('admin_menu','create_forum', 'edit_forums', 'edit_site', 
		'manage_owners', 'list_forums', 'help', 'login');
	}
	else {
		push(@list, 'admin_menu');
		if($create_f_right eq "YES"){
			push(@list, 'create_forum');
		}
		push(@list, 'edit_forums', 'change_pass','list_forums', 'help', 'login');
	}    

###ISU CHANGE##################
if ($in{'owner_code_name'} eq 'cnet') {
   @list = ();
   push(@list,'help');
}	
###############################
	
	$llength = @list;
	
	for($i=0; $i<$llength; $i++){
		if($list[$i] ne $no_no_button){
			push(@admin_icon_list, $list[$i]);
		}
	}

}
sub check_user {

	local($owner_code_name, $id) = @_;
	local($user,  $pass, $owner_full_name);

	$user_list_file = "$home_directory/admin/userlist";
	
	if(!(-e $user_list_file)){
		&doh("There are NO forum owners in the system now! - check_user");
	}
	elsif(-z $user_list_file){
		&doh("There are NO forum owners in the system now! - check_user");
	}
	else{
		open(USER_LIST, $user_list_file) || 
		&doh("Unable to open user list file: $user_list_file - check_user");
		&lock(USER_LIST);
		while($line = <USER_LIST>)
		{
			($user, $admin_right, $create_f_right, $delete_f_right, $edit_f_right, $config_f_right, 
			$edit_t_right, $pass, $owner_full_name) = split(/:/, $line);
			if($user eq $owner_code_name){
				if($id ne $pass){
					&doh("Identification failed: Invalid password. - check_user");	
				}
				$found = 1;
				last;
			}
		}
		close(USER_LIST);
		&unlock(USER_LIST);
		if(!($found)){
			&doh("Identification failed: Owner name not found. - check_user");
		}
	}
}


sub get_forum_owner{

	local($forum_owner_code_name) = @_;
	local($o_code, $a_right, $f_right, $d_right, $e_right, $c_right, $t_right, $pas, $forum_owner);
	
	$userlist = "$home_directory/admin/userlist";
	open(USER_LIST, "$userlist") 
	|| &doh("Cannot open user file: $userlist - start_forum");
	&lock(USER_LIST);
	while($line = <USER_LIST>)
	{
		($o_code, $a_right, $f_right, $d_right, $e_right, $c_right, $t_right, $pas, $forum_owner) 
		= split(/:/, $line);
		last if ($o_code eq $forum_owner_code_name);
	}
	close(USER_LIST);
	&unlock(USER_LIST);
	
	chop($forum_owner);
	return($forum_owner);
}

sub edit_forum_topics {

    ($owner_code_name,$id) = @_;
    if((!($owner_code_name)) || (!($id))){
       $owner_code_name = $in{'owner_code_name'};
       $id = $in{'id'};
    }
    &check_user($owner_code_name, $id);
    &check_toolbar;
    # This code looks similar to show_topics in main
	
    $which_forum = $in{'forum_code'};
    &parse_a;
    $forum_name = $in{'forum_name'};
    $forum_code = $in{'forum_code'};
    $forum_owner = $in{'forum_owner'};
    $owner_code = $in{'owner_code'};

    local($item, $item_counter, $file_path, $num_messages);
    unless ($httpheader) {print &http_header};
    print "<title>$forum_name - Topics</title>\n";
    &header;
    print "<h3>NetForum Administration : Edit Forums </h3><P>";
    print "<h2>Edit Forum's Topics and Messages</h2>";
    print "<HR>";
    &admin_footer($owner_code_name, $id);
    print "<HR>";
    print "<b>Forum Name:</b>";

    if($cgi_required){
       print "<a href=\"$url/$base_url/$which_forum/a.cgi/$show_topics_command\">";
    }
    else{
    print "<a href=\"$url/$base_url/$which_forum/a/$show_topics_command\">";
    }
    print "$forum_name</a><BR>";
    
    print "<B>Forum Code:</B> $forum_code<BR>";
    print "<b>Forum Owner:</b> ";

    if (($forum_owner_site =~ /http\:\/\//) && 
	($forum_owner_site ne 'http://')) {

	print "<a href=\"$forum_owner_site\">";
    }

    print $forum_owner;

    if (($forum_owner_site =~ /http\:\/\//) && 
	($forum_owner_site ne 'http://')) { 

	print "</a>";
    }

    if ($forum_owner_email) 
    {
		$aa = $forum_owner_email;
		if($nf_mail) 
		{
			$aa =~ s/\\@/$mail_separator/;
			print " (<a href=\"/$netforum_url/$mail_command$cvar_separator";
			print "$aa\">$forum_owner_email</a>)\n<br>\n";
    	}
    	else
    	{
    		print " (<a href=\"mailto:$aa\">$aa</a>)\n<br>\n";

    	}	
    }
    else {

	print "\n<br>\n";
    }

    print "<B>Owner Code:</b> $owner_code<Br>";
    print "<b>Contact:</b> ";

    if (($forum_monitor_site =~ /http\:\/\//) 
	&& ($forum_monitor_site ne 'http://')){

	print "<a href=\"$forum_monitor_site\">";
    }

    print $forum_monitor;

    if (($forum_monitor_site =~ /http\:\/\//) 
	&& ($forum_monitor_site ne 'http://')){

	print "</a>";
    }

    $aa = $forum_monitor_email;
    if($nf_mail)
    {
    	$aa =~ s/\\@/$mail_separator/;
    	print " (<a href=\"/$netforum_url/$mail_command$cvar_separator";
    	print "$aa\">$forum_monitor_email</a>)\n<br>";
    }
    else
    {	
    	$aa =~ s/\\//;
    	print " (<a href=\"mailto:$aa\">$aa</a>)\n<br>\n";
    }

    if (-e "$home_directory/$which_forum/description"){

	open(DESC, "$home_directory/$which_forum/description") || 
	    &doh('Can\'t open description file - edit_forum_topics');
	&lock(DESC);
	# print "\n<hr>\n";
	print "<B>Description:</b>";
	while (<DESC>){print};
	close(DESC);
	&unlock(DESC);
    }
    print "\n<hr>\n<H3>Topics:</H3>\n<ul>\n";
       
	# check if file is empty
	
	 $list_file = "$home_directory/$which_forum/topics/list";
	if (!(-s $list_file))
	{
		print "\n<dd><b>No Topics</b>\n";
	}
    else {
		open(TOPICS_LIST, $list_file) ||
		&doh("Couldn\'t find topics list file: $list_file");
		&lock(TOPICS_LIST);
		while($line = <TOPICS_LIST>) {
# 		foreach $item sort( keys %topics_list) 
		# parse topic numbers and topic names:
		($which_topic, $num_messages, $num_replies, $item, $udate) = split(/:/, $line, 5);
			$which_topic =~ s/\s//g;
	    	next if ($item eq $empty_topic);

	    	print "<li> <b>$item</b>\n";
	    	if ($num_messages == 0) {
				print("\t<dd> (no messages)\n");
	    	} 
	    	else {
				print("\t<dd> ($num_messages");
				if ($num_messages == 1) {
		    		print " message, ";
				}
				else {
		    		print " messages, ";
				}
				print "$num_replies";
			    if($num_replies ==1) {
					print " reply, ";
			    }
			    else {
					print " replies, ";
			    }
			    print "last message/reply posted $udate)";
	    	}

print "<FORM ACTION=\"/$netforum_url/$topic_admin_command\" METHOD=POST>\n";

print "<INPUT TYPE=\"hidden\" NAME=\"owner_code_name\" VALUE=\"$owner_code_name\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"id\" VALUE=\"$id\">\n";

print "<INPUT TYPE=\"hidden\" NAME=\"which_topic\" VALUE=\"$which_topic\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"which_forum\" VALUE=\"$which_forum\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"forum_code\" VALUE=\"$forum_code\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"forum_owner\" VALUE=\"$forum_owner\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"owner_code\" VALUE=\"$owner_code\">\n";
print "<INPUT TYPE=\"hidden\" NAME=\"forum_name\" VALUE=\"$forum_name\">\n";
print "<INPUT TYPE=\"radio\" NAME=\"topic_action\" VALUE=\"delete_verify\">Delete Topic\n";
print "<INPUT TYPE=\"radio\" NAME=\"topic_action\" VALUE=\"edit_topic\">Edit Topic\n";
print "<INPUT TYPE=\"radio\" NAME=\"topic_action\" VALUE=\"edit_messages\">Edit Topic's Messages\n";
print "<INPUT TYPE=\"submit\" VALUE=\"submit\">\n";
print "</FORM>\n";
		}
		close(TOPICS_LIST);
		&unlock(TOPICS_LIST);
    }
    print "</ul>\n<hr>\n";
    
    &footer;
}

sub admin_footer {

	($owner_code_name,$id) = @_;
	if((!($owner_code_name)) || (!($id))){
		$owner_code_name = $in{'owner_code_name'};
		$id = $in{'id'};
	}
	
    print "\n";
    print "<TABLE>";
    print "<TR>";
    foreach $icon (@admin_icon_list){
    	if ($icon eq 'admin_menu'){	
    	    print "\n<FORM ACTION=\"/$netforum_url/$admin_options_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";	
    		
   			print "<TD>";
    		print "<input type=\"image\" alt=\"Go to admin menu\" ";
    		print "SRC=\"$goto_admin_gif\" name=\"admin_menu\" BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";  		
    	}
    	if($icon eq 'create_forum'){
    		print "\n<FORM ACTION=\"/$netforum_url/$main_menu_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";
    		print "<input type=\"hidden\" name=\"action\" value=\"create_forum\"> ";
    	
   			print "<TD>";
    		print "<input type=\"image\" alt=\"Create forum\" ";
    		print "SRC=\"$create_forum_gif\" name=\"create_forum\"  BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";
    	}
    	if($icon eq 'edit_forums'){
    		print "\n<FORM ACTION=\"/$netforum_url/$main_menu_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";
    		print "<input type=\"hidden\" name=\"action\" value=\"edit_forum\">	";
    		
   			print "<TD>";
    		print "<input type=\"image\" alt=\"Edit forums\" ";
    		print "SRC=\"$edit_forums_gif\" name=\"edit_forums\"  BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";
    	}
    	if($icon eq 'edit_site'){
    		print "\n<FORM ACTION=\"/$netforum_url/$main_menu_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";
	   		print "<input type=\"hidden\" name=\"action\" value=\"site_config\">";
	   		
   			print "<TD>";
    		print "<input type=\"image\" alt=\"Edit site\" ";
    		print "SRC=\"$edit_site_gif\" name=\"edit_site\"  BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";
    	}
    	if($icon eq 'manage_owners'){
    		print "\n<FORM ACTION=\"/$netforum_url/$main_menu_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";
    		print "<input type=\"hidden\" name=\"action\" value=\"manage_owners\">";
    		
   			print "<TD>";
    		print "<input type=\"image\" alt=\"Manage Forum Owners\" ";
    		print "SRC=\"$manage_owners_gif\" name=\"manage_owners\"  BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";
    	}
    	if($icon eq 'list_forums'){
    		print "\n<FORM ACTION=\"/$netforum_url/$main_menu_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";
	   		print "<input type=\"hidden\" name=\"action\" value=\"list_forums\">";
	   	
   			print "<TD>";
    		print "<input type=\"image\" alt=\"List forums\" ";
    		print "SRC=\"$list_forums_gif\" name=\"list_forums\"  BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";
    	}
    	if($icon eq 'change_pass'){
    		print "\n<FORM ACTION=\"/$netforum_url/$main_menu_command\"";
    		print "METHOD=POST>\n";
    		print "<input type=\"hidden\" name=\"owner_code_name\" value=\"$owner_code_name\">\n";
    		print "<input type=\"hidden\" name=\"id\" value=\"$id\">\n";
	   		print "<input type=\"hidden\" name=\"action\" value=\"change_pass\">";	
	   		
   			print "<TD>";
    		print "<input type=\"image\" alt=\"Change Password\" ";
    		print "SRC=\"$change_pass_gif\" name=\"change_pass\"  BORDER=$image_border>\n";
    		print "\n</TD>"; 
   		    print "</FORM>";
    	}
    	if($icon eq 'help'){
    		print "<TD>";
    		print "<a target=\"new_window\" href=\"$docs/Docs";
    		print "/OnLine/maintenance.html\">";
    		print "<IMG BORDER=";
            print "$image_border ALT=\"Help\" SRC=\"$help_gif\"></A>\n";
	    print "</TD>";
    	}
    	if ($icon eq 'login'){
    		
    		print "<TD>";
    		print "<a href=\"$url/$netforum_url\"> ";
    		print "<IMG SRC=\"$goto_login_gif\" name=\"login\" BORDER=$image_border";
    		print " alt=\"Go to login page\"></a>\n";
    		print "\n</TD>"; 
    	}
    }
    print "</TR></TABLE>";

}


1;

