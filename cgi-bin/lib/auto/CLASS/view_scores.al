# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub view_scores {
   my ($self,$stud_names,$asn_names,$inst) = @_;
   my $tot_pts_rec = 0;
   my $tot_pts = 0;
   my @asn_files;
   my %asn_info = {};

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   # Grade ungraded assignments. 
   foreach $sname (@{$stud_names}) {
       my $stud = $self->get_member("",$sname);
       foreach $aname (@{$asn_names}) {
           my $asn = $self->get_assignment("",$stud,$aname);
           $asn->grade_ungraded();
       }
   } 

   # Get an associative array of assignment types
   foreach $asn_name (@{$asn_names}) {
       my $disk_name = CGI::escape($asn_name);
       my %info = ASSIGNMENT->get_info($self,$asn_name);
       $asn_info{$asn_name} = \%info;
   }

   my $hasTable = CN_UTILS::hasTables();
   # Loop on students and assignments
   my $detail = "<CENTER><H3>Details</H3></CENTER>\n";
   TEST::print_test_header('Scores');
   print "<CENTER><H4>$self->{'Name'}</H4></CENTER>$GLOBALS::HR\n";
   print "<CENTER><H3>Summary</H3></CENTER><P>\n";
   if ($hasTable) {
       print "<TABLE border=1 cellpadding=2 width=100%>";
       print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>Student Name\n";
       print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>Earned\n";
       print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>Possible\n";
   } else {
       printf("<PRE>%-20s%10s%10s",'Student Name','Earned','Possible');
   }
   my $tabstr = "Student Names";
   foreach $asn_name (@{$asn_names}) {
       my $pts = $asn_info{$asn_name}{'TP'};
       my $asn_type = $asn_info{$asn_name}{'Assignment Type'};
       if ($asn_type =~ /EVAL/) {
         $pts = 0;
       }
       if ($hasTable) {
           print "<TH ALIGN=CENTER BGCOLOR='#c0c0c0'>$asn_name($pts pts)\n";
       } else {
           printf("%15s(%s pts)",$asn_name,$pts);
       }
       $tabstr .= "\t$asn_name($pts pts)"; 
   }
   if ($hasTable) {
       print "<TR BGCOLOR='#FFFFFF'>\n";
   } else {
       print "<BR>\n";
   }
   $tabstr .= "\n";
   foreach $stud_name (@{$stud_names}) {
       $detail .= "<HR><CENTER><H5>$stud_name</H5></CENTER>\n";
       if ($hasTable) {
           print "<TD ALIGN=LEFT>$stud_name\n";
       } else {
           printf("%-20s",$stud_name);
       }
       $tabstr .= "$stud_name";
       my $line = '';
       my $pts;
       foreach $asn_name (@{$asn_names}) {
           my $asn_type = $asn_info{$asn_name}{'Assignment Type'};
           my @scores = ($asn_type)->get_score($self,$asn_name,$stud_name);
           $pts = $scores[2];
           if ($pts =~ /(\?|\*|\-|\#)/) {
             if ($pts =~ /(\d+)\?/) {
                 $pts = $1;
             } else {
                 $pts = 0;
             }
           }
       	   if ($hasTable) {
               $line .= "<TD ALIGN=RIGHT>$scores[2]\n";
           } else {
               $line .= sprintf("%15s","$scores[2]");
           }
           $tabstr .= "\t$scores[2]"; 
       	   $tot_pts += $scores[1];
       	   $tot_pts_rec += $pts;
           $detail .= "$scores[0]\n";
       }
       $tabstr .= "\n";
       if ($hasTable) {
           print "<TD ALIGN=RIGHT>$tot_pts_rec<TD ALIGN=RIGHT>$tot_pts\n";
           print "$line<TR BGCOLOR='#FFFFFF'>\n";
       } else {
           printf("%10s%10s%s<BR>\n",$tot_pts_rec,$tot_pts,$line);
       }
       $tot_pts = $tot_pts_rec = 0;
   }
   if ($hasTable) {
       print "</TABLE>\n";
   } else {
       print "</PRE><BR>\n";
   }
   print "- = not seen or seen but not submitted<BR>";
   print "* = submitted but awaiting due date<BR>";
   print "? = requires instructor grading<BR>";
   print "# = non-scored evaluation or survey<BR>";
   my $script = "gradebook";                                          
   if ($inst->{'Member Type'} =~ /student/) {                         
        $script = "student";                                          
   }                                                                  
   print <<"FORM";                                                    
<FORM METHOD=POST ACTION=$GLOBALS::SCRIPT_ROOT/$script>               
<INPUT TYPE=hidden NAME="Class Name" VALUE="$self->{'Name'}">         
<INPUT TYPE=hidden NAME="Ticket" VALUE="$inst->{'Ticket'}">   
<INPUT TYPE=hidden NAME=cn_option VALUE="Mail Table">                 
<INPUT TYPE=hidden NAME=table VALUE="$tabstr">                        
<CENTER>                                                              
<img src="$GLOBALS::SERVER_IMAGES/new_tiny.gif"><P>       
</CENTER>                                                             
<BLOCKQUOTE>                                                          
You may mail a text version of the summary table to yourself. Columns 
will be separated by tabs making the file suitable for importing into 
a spreadsheet.                                                        
</BLOCKQUOTE>                                                         
<P>                                                                   
<CENTER>                                                              
<INPUT TYPE=submit NAME=mailTable VALUE="Mail">                       
</CENTER>                                                             
FORM
   print $detail;
   print "</BODY>\n</HTML>\n";
   exit(0);
}

1;
