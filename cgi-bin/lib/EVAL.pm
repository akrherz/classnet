package EVAL;
use Exporter;
@ISA = (Exporter, TEST);

#########
=head1 EVAL

=head1 Methods:

=cut
#########

require TEST;

#########################################
=head2 new($query, $cls, $member, $assign_name)

=over 4

=item Description

=item Params

=item Instance Variables

=item Returns
EVAL object

=back

=cut

sub new {
   my($class, $query, $cls, $member, $assign_name) = @_;
   my $self = TEST->new($query,$cls,$member,$assign_name);
   bless $self, $class;
   return $self;
}

sub send_edit_form {
   my ($self,$query,$stu) = @_;
   my ($q_name,@q_names,$stud_ans);

   ERROR::print_error_header('Edit?');
   print "You may not view individual responses of a class evaluation.";
   CN_UTILS::print_cn_footer();
   exit(0);
}

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $escaped_asn_name = CGI::escape($asn_name);
   my $escaped_stud_name = CGI::escape($stud_name);
   my $text;

   # Set input record separator and read the file
   $/ = "\n";

   # Set input record separator and read the file
   my $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/graded/$escaped_asn_name";
   my $pr = '-';
   if (-e $path) {
       open(ASN,"<$path") or
           ERROR::system_error("EVAL","get_score","open",$path);
       flock(ASN,$LOCK_EX);
       my $test_header = <ASN>;
       flock(ASN,$LOCK_UN);
       close(ASN);
       my %scores = TEST->unpack_stud_test_header($test_header);
       (%scores) or
            ERROR::system_error('EVAL','get_score','unpack stheader',
                                "$path:$test_header");
       $tp = 0;
       $scores{'SUBMIT'} = 1;
       $pr = '#';
       $text = "<B>$asn_name:</B> non-scored evaluation or survey";
       my $seen = $scores{'SEEN'};
       if (defined $seen) {
          $text .= "<BR>First Seen on $seen";
       }
       my $subdate = $scores{'SUBDATE'};
       if (defined $subdate) {
          $text .= "<BR>Submitted on $subdate";
       }
       my $date = CN_UTILS::getTime($path);
       $text .= "<BR>Graded on $date<BR>";
       return ($text,$tp,$pr);
    } else {
       $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/ungraded/$escaped_asn_name";
       $text = "<B>$asn_name:</B> ";
       if (-e $path) {
           my $date = CN_UTILS::getTime($path);
           open(ASN,"<$path") or
               ERROR::system_error('TEST','read','open',$path);
           my $adata = <ASN>;
           close(ASN);
           if ($adata =~ /SUBMIT=0/) {
               $text .= "(seen on $date but not yet submitted)<BR>";
           } else {
               $pr = '*';
               $text .= "(submitted on $date but not yet graded)<BR>";
           }
       } else {
           $text .= "(not seen)<BR>";
       }
       return ($text,$1,$pr);
    }
}

sub mail_raw_data {
    my ($self,$stud_names) = @_;
    my $cls = $self->{'Class'};
    my @snames = $cls->get_mem_names('student');
    my @snames1 = @{$stud_names};
    my $n = @snames;
    my $n1 = @snames1;
    if ($n != $n1) {
        ERROR::print_error_header('Data for Evaluation');
        print "You may only print evaluation data for ALL students.";
        CN_UTILS::print_cn_footer();
        exit(0);
    }
    # Randomize the student names
    my @rand_array;
    push(@rand_array,splice(@snames1,rand(@snames1),1))
        while @snames1;
    ASSIGNMENT->mail_raw_data($self,\@rand_array);
}

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = "\n***NEW RANDOM EVAL***\n";
    my $name = $self->{'Name'};
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $answers = $self->{'Stud Answers'};
        my $nb = $self->block_count();
        for ($i=1;$i <= $nb; $i++) {
            my $key = "$i.1";
            if (defined $answers->{$key}{'ANS'}) {
                $ans = $answers->{$key}{'ANS'};
                $body .= "\n$ans";
            } else {
                my $j = 1;
                $body .= "\n";
                while (defined $answers->{"$key.$j"}{'ANS'}) {
                    $ans = $answers->{"$key.$j"}{'ANS'};
                    $body .= "|$ans";
                    $j++;
                }
            }
        }
    }
    $body .= "\n";
}

1;

