#!/usr/bin/perl
#sub upload {
#    my ($self,$url) = @_;

    #my $hfile = ASSIGNMENT::upload($self,$url);
    $/='';
    open(F,"<test.html");
    $hfile = <F>;
    close F;
    @questions = split(/<HR>/,$hfile);
    # throw away stuff before first <HR>
    shift @questions;
    $b = 0;
    foreach $quest (@questions) {
        #%params = unpack_block_header(<CN_BLOCK PTS=0/1>);
        $params{"TP"} = 1;
        $params{"PP"} = 0;
        $b++;
        #($b > 1) and $self->insert_block($b);
        if ($b > 1) { print "insert block $b\n"; }
        $params{'btext'} = '';
        #$self->write_block($b,%params);
        $qhdr = "<CN_Q>";
        $i = 0;
        if ($quest =~ s/<INPUT[^>]*TYPE=\"?RADIO\"?[^>]*>/eval {$i++;"<?>"}/eig) {
           $qhdr = "<CN_Q TYPE=CHOICE N=$i>";
        }
        if ($quest =~ s/<INPUT[^>]*TYPE=\"?CHECKBOX\"?[^>]*>/eval {$i++;"<?>"}/eig) {
           $qhdr = "<CN_Q TYPE=MULTIPLE N=$i>";
        }
        if ($quest =~ s/<INPUT(\s*NAME=\"?\S*\"?|\s*TYPE=\"?TEXT\"?|\s*SIZE=\"?(\d+)\"?)+\s*>/eval
           { $i = defined $2?$2:5;
             "<?>    <\/?>"
           }/eig) {
           $qhdr = "<CN_Q TYPE=BLANK JUDGE=NOJUDGE N=$i>";
        }
        if ($quest =~ s/<TEXTAREA(\s*ROWS=\"?(\d+)\"?|\s*COLS=\"?(\d+)\"?)+[^>]*>/<?>/ig) {
           $quest =~ s/<\/TEXTAREA>/<\/?>/ig;
           $r = defined $2?$2:5;
           $c = defined $3?$3:50;
           $qhdr = "<CN_Q TYPE=ESSAY ROWS=5 COLS=50>";
        }
        if ($quest =~ s/<SELECT[^>]*>/<?>/ig) {
           $quest =~ s/<OPTION>/eval { $i++; "<?>"}/eig;
           $quest =~ s/<OPTION SELECTED>/eval { $i++; "<?>"}/eig;
           $quest =~ s/<\/SELECT>/<\/?>/ig;
           $qhdr = "<CN_Q TYPE=OPTION N=$i>";
        }
        $quest =~ s/<\/FORM>//ig;
        $quest =~ s/<\/BODY>//ig;
        $quest =~ s/<\/HTML>//ig;
        #my %params = unpack_question_header($qhdr);
        $params{'qtext'} = "$quest\n<CN_FEEDBACK>\n";
        $qtext = $params{'qtext'};
        print "question $q:$qhdr\n$qtext\n";
        #$self->write_question($b,1,%params);
    }


