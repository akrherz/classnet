# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub replace_placeholders {
   my ($self, $val, $block_num, $question_num, %q_params) = @_;
   my $name = "$block_num.$question_num";
   my $q_str = $q_params{'qtext'};

   $_ = $q_params{'Question Type'};
   SWITCH: {
       /CHOICE|LIKERT/  &&
       	   do {
       	       my $j=0;
       	       $q_str =~ s/<\?>/eval 
                   { $j++; my $check = ($j == $val) ? "CHECKED" : "";
       	       	     "<INPUT TYPE=radio NAME=\"$name\" VALUE=$j $check> " 
                   }/eg;
       	       last SWITCH;
       	      };

       /MULTIPLE/  &&
       	   do {
       	       my $j=0;
               my @picks = split(/%2C/,$val);
       	       $q_str =~ s#<\?>#eval 
                   { $j++; $check = '';
                     foreach $num (@picks) {
                         if ($num == $j) {
                             $check = 'CHECKED';
                             last;
                         }
                     }
       	       	     "<INPUT TYPE=checkbox NAME=$name.$j VALUE=1 $check> " 
                   }#eg;
       	       last SWITCH;
       	      };

       /BLANK/ &&
       	   do {
       	       my $j=0;
       	       # Can't use $val alone because it could be zero;
       	       if ($val ne '') {
       	       	   # split on any escaped commas
       	       	   my @ans_array = split(/%2C/,$val);
                   my @blanks = split(/<\/\?>/,$q_str);
                   my $j = 0;
                   $q_str = '';
                   foreach $blank (@blanks) {
                       $j++;
                       if ($blank =~ /((.|\n)*)<\?>(.*)/) {
                           $n=length($3);
                           $q_str .= "$1 <INPUT NAME=$name.$j SIZE=$n VALUE=\"$ans_array[$j-1]\"> "
                       } else {
                           $q_str .= $blank;
                       }
                   }
       	       }
       	       else {
                   my @blanks = split(/<\/\?>/,$q_str);
                   my $j = 0;
                   $q_str = '';
                   foreach $blank (@blanks) {
                       $j++;
                       if ($blank =~ /((.|\n)*)<\?>(.*)/) {
                           $n=length($3);
                           $value = $n > 0 ? "VALUE=\"$3\"" : "";
                           $q_str .= "$1 <INPUT NAME=$name.$j $value SIZE=$n> ";
                       } else {
                           $q_str .= $blank;
                       }
                   }
       	       }
       	       last SWITCH;
       	      };

       /ESSAY/ &&
       	   do {
       	       my ($rows, $cols);
               $q_params{'ROWS'} and $rows = "ROWS=$q_params{'ROWS'}";
               $q_params{'COLS'} and $cols = "COLS=$q_params{'COLS'}";
       	       if ($val eq "") {
       	       	   if ($q_str =~ m/<\?>(.*)<\/\?>/si) {
       	       	       $val = $1;
       	       	       !($val =~ /\S/) and
       	       	       	   $val="";
       	       	   }
       	       }
       	       $q_str =~ s/<\?>.*<\/\?>/<TEXTAREA NAME=\"$name\" $rows
$cols WRAP=physical>$val<\/TEXTAREA> /si;
       	       last SWITCH;
       	      };
       /OPTION/ &&
       	   do {
               ($q_str,$rest) = split(/<\/\?>/,$q_str);
	       # I am not sure why we have to reverse it here, just append </SELECT> below 
       	       #$q_str = reverse $q_str;
       	       #$q_str =~ s/([\n?.*>\?]{1}?)/>TCELES<\n$1/;
       	       #$q_str = reverse $q_str;
       	       $q_str =~ s/(<\?>)/<SELECT NAME=\"$name\"> \n$1/;
       	       $q_str =~ s/<\?>/<OPTION> /g;
      	       # Can't use $val alone because it could be zero;
               ($val ne "") and
       	       	   $q_str =~ s/<OPTION>([\s|\n]*$val[\s|<|\n])/<OPTION SELECTED> $1/s;
               $q_str .= "</SELECT>\n$rest";
       	       last SWITCH;
       	      };
       /LIST/ &&
       	   do {
       	       my $size;
               ($q_str,$rest) = split(/<\/\?>/,$q_str);
               $q_params{'ROWS'} and $size = "SIZE=$q_params{'ROWS'}";
       	       #$q_str = reverse $q_str;
       	       #$q_str =~ s/([\n?.*>\?]{1}?)/>TCELES<\n$1/;
       	       #$q_str = reverse $q_str;
       	       $q_str =~ s/(<\?>)/<SELECT NAME=\"$name\" $size> \n$1/;
       	       $q_str =~ s/<\?>/<OPTION> /g;
      	       # Can't use $val alone because it could be zero;
               ($val ne "") and
       	       	   $q_str =~ s/<OPTION>([\s|\n]*$val[\s|<|\n])/<OPTION SELECTED> $1 /s;
               $q_str .= "</SELECT>\n$rest";
       	       last SWITCH;
       	      };
       }
       return $q_str;
}

1;
