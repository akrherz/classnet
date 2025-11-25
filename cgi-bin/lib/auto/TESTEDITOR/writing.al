# NOTE: Derived from lib/TESTEDITOR.pm.  Changes made here will be lost.
package TESTEDITOR;

#########################################

sub writing {
    my ($self,$b,$q) = @_;
    my $asn = $self->{'Assignment'};
    my $cls = $asn->{'Class'};
    my $develop = "$cls->{'Root Dir'}/assignments/.develop";
    my $flag = "$develop/.flag";
    my $query = $asn->{'Query'};
    if ($query->param('back')) {
       unlink $flag;
       $self->print_edit_header();
       $self->print_footer();
       exit(0);
    }
    $_ = $query->param('section_type');
    SWITCH: {
        /^asn/  &&
           do  {
                 if ($query->param('duedate')) {
                     if (($query->param('duedate') =~ /^(\d{2}:\d{2}:)?([01]\d?)\/([0-3]\d?)\/(\d{4})$/)) {
                         if (($2 == 2 and $3 > 29) or ($3 > 31)) {
                             $self->print_help('The value for days is too large.');
                         }
                         my $tm = $1;
                         if ($tm =~ /(\d{2}):(\d{2}):/) {
                             if ($1 > 23 or $2 > 59) {
                                 $self->print_help('The value for hours or minutes is too large.');
                             }
                         }
                     } else {
                         $self->print_help('Enter date in the form mm/dd/yyyy (e.g. 01/05/1997) or hh:mm:mn/dd/yyyy (e.g. 13:30:01/05/1997)');        
                     }
                 }
                 my %params = {};
                 $params{'Assignment Type'} = $query->param('Assignment Type');
                 ($query->param('duedate')) and 
                     $params{'DUE'} = $query->param('duedate');
                 ($query->param('password')) and 
                     $params{'PASSWORD'} = $query->param('password');
                 (defined $query->param('fill')) and 
                     $params{'FILL'} = 1;
                 (defined $query->param('view')) and 
                     $params{'VIEW'} = 1;
                 (defined $query->param('mult')) and 
                     $params{'MULT'} = 1;
                 if ($query->param('rand') eq 'vers') { 
                     $params{'VERS'} = $query->param('versions');
                 } else {
                     $params{'RAND'} = 1;
                 }
                 $params{'TP'} = $query->param('TP');
                 unlink $flag;
                 $asn->write(%params);
                 $asn->put_extra_fields($query);
                 if (defined $query->param('publish')) { 
                     $asn->publish();
                 } else {
                     $asn->unpublish();
                 }
                 last SWITCH;
           };

        /^blk/  &&
           do  {
                 my %params = {};
                 my $tc = $query->param('tcredit');
                 my $pc = $query->param('pcredit');
                 if (($tc =~ /\./) || ($pc =~ /\./)) {
                     $self->print_help('Points must be whole numbers.');
                 }
                 if ($tc =~ /\s*(\d+)\s*/) {
                     $params{'TP'} = $1;
                     if ($pc =~ /\s*(\d+)\s*/) {
                         $params{'PP'} = $1;
                         if ($params{'PP'} > $params{'TP'}) {
                             $self->print_help('Partial points must be less than or equal to total points.');
                         }
                     } elsif (!($pc =~ /\s*/)) {
                         $self->print_help('Enter a number or leave Partial blank.');
                     }
                 } elsif ($tc =~ /\s*/) {
                     $self->print_help('Enter a number or leave Total blank.');
                 }
                 $params{'Name'} = $query->param('name');
                 $params{'btext'} = $query->param('btext');
                 unlink $flag;
                 $asn->write_block($b,%params);
                 last SWITCH;
           };

        /^qst/  &&
           do  {
                 my $ldelim = '&lt;?&gt;';
                 my $rdelim = '&lt;/?&gt;';
                 my %params = {};
                 $params{'Question Type'} = $query->param('Question Type');
                 $ans = $query->param('ANS');
                 my $qtext = CN_UTILS::remove_spaces($query->param('qtext'));
                 $params{'qtext'} = $qtext;
                 if ($params{'Question Type'} eq 'CHOICE') {
                     for ($n = 0; $qtext =~ /<\?>/g; $n++) {};
                     if ($n == 0) {
                         $self->print_help('For CHOICE, use $ldelim in front of each answer.');
                     }
                     unless (($ans eq '') or
                         ($ans =~ /{\s*\w+\s*}/) or 
                         ($ans >= 1 and $ans <= $n)) {
                         $self->print_help("For CHOICE, answer should be a number between 1 and $n.");
                     };
                 } elsif ($params{'Question Type'} eq 'LIKERT') {
                     for ($n = 0; $qtext =~ /<\?>/g; $n++) {};
                     if ($n == 0) {
                         $self->print_help('For LIKERT, use $ldelim to mark your choices.');
                     }
                     unless (($ans eq '') or
                         ($ans =~ /{\s*\w+\s*}/) or 
                         ($ans =~ /^\s*[+-]?\d+(\s*,\s*[+-]?\d+\s*)*\s*$/)) {
                         $self->print_help("For LIKERT, answer should be
blank or a list of numbers (weights) separated by commas.");
                     };
                 } elsif ($params{'Question Type'} eq 'BLANK') {
                     for ($i = 0; $qtext =~ /<\?>/g; $i++) {};
                     for ($n = 0; $qtext =~ /<\/\?>/g; $n++) {};
                     if ($i == 0 || $n == 0) {
                         $self->print_help("For BLANK, use $ldelim xxx
$rdelim to mark the location, size and initial value.");
                     }
                     if ($i != $n) {
                         $self->print_help("Mismatched delimiters (i.e. $ldelim or $rdelim).");
                     }
                     if ($i != split(/,/,$ans)) {
                         $self->print_help("The number of answers and blanks don't agree.");
                     }
                     $params{'N'} = $i;
                 } elsif ($params{'Question Type'} eq 'MULTIPLE') {
                     for ($i = 0; $qtext =~ /<\?>/g; $i++) {};
                     if ($i == 0) {
                         $self->print_help("For MULTIPLE, precede each option by a $ldelim.");
                     }
                     $params{'N'} = $i;
                 } elsif ($params{'Question Type'} eq 'ESSAY') {
                     for ($i = 0; $qtext =~ /<\?>/g; $i++) {};
                     for ($n = 0; $qtext =~ /<\/\?>/g; $n++) {};
                     if ($i !=1 || $n != 1) {
                         $self->print_help("For ESSAY, mark location
and size of editor by one pair of $ldelim...$rdelim.");
                     }
                     $params{'N'} = $i;
                 }
                 $params{'ANS'} = $ans;
                 $params{'feedback'} = CN_UTILS::remove_spaces($query->param('feedback'));
                 if ($query->param('rows') =~ /\s*(\d+)\s*/) {
                     $params{'ROWS'} = $1;
                     ($params{'Question Type'} eq 'BLANK') and
                         $params{'ROWS'} = 1;
                 }
                 if ($query->param('cols') =~ /\s*(\d+)\s*/) {
                     $params{'COLS'} = $1;
                 }
                 if ($query->param('jtype') eq 'numeric') {
                     $judge = 'NUM';
                 } else {
                     if ($query->param('exact')) {
                         $judge .= $judge? ',EXACT':'EXACT';
                     } else {
                         $judge .= $judge? ',NOEXACT':'NOEXACT';
                         ($query->param('caps')) and $judge .= ',CAPS';
                         ($query->param('spell')) and $judge .= ',SPELL';
                         ($query->param('punc')) and $judge .= ',PUNC';
                         ($query->param('order')) and $judge .= ',ORD';
                         ($query->param('count')) and $judge .=',CNT';
                     }
                 }
                 $params{'JUDGE'} = $judge;
                 if (defined $query->param('view')) {
                     TEST->print_test_header('Test Question','View');
                     print "<FORM METHOD=POST>\n";
                     print $asn->replace_placeholders("",$b,$q,%params);
                     print "</FORM>\n";
                     $self->print_footer();
                     exit(0);
                 }
                 unlink $flag;
                 $asn->write_question($b,$q,%params);
                 last SWITCH;
           };
    };
    $self->print_edit_header();
    $self->print_footer();
}

1;
