# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub get_stats {
    my ($class, $self, $stats, $tot) = @_;
    # Handle both method and legacy calls
    if (ref($class)) { $tot = $stats; $stats = $self; $self = $class; }
    my $name = $self->{'Name'};
    my $type;

    # Has key been read or constructed? 
    # Need key for differentiating question types
    $self->{'Key'} or $self->read_key();
    my $ans_key = $self->{'Key'};

    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $answers = $self->{'Stud Answers'};
        # if there are categories, then get the subcategory stat tables
        foreach $cat (split(/,/,$self->{'Categories'})) {
            foreach $key (keys %{$answers}) {
    	        $key =~ m/(\d+).(\d+)/;
                if ($1 eq $cat) {
    	            $type = $ans_key->{"$1.$2"}{'Question Type'};
                    if ($type =~ m/ESSAY/i || 
                        $type =~ m/BLANK/i ||
                        $type =~ m/MULTIPLE/i) {
		           ERROR::user_error($ERROR::NOTDONE,"categorize on ESSAY, BLANK or MULTIPLE questions.");
                    }
                    my $ans = $answers->{$key}{'ANS'};
                    if (!defined $stats->{$ans}) {
                       my %st = {};
                       $stats->{$ans} = \%st;
                    }
                    $stats = $stats->{$ans};
                    break;
                }
            }
        }
        foreach $key (keys %{$answers}) {
    	    $key =~ m/(\d+).(\d+)/;
    	    $type = $ans_key->{"$1.$2"}{'Question Type'};
            $ans = $answers->{$key}{'ANS'};
            if (defined $stats->{$key}) {
    	    	if ($type =~ m/ESSAY/i) {
    	    	    (length($ans) > 0) and
    	    	    	$stats->{$key} .= $ans . "<BR><HR>";
        	} elsif (defined $stats->{$key}{$ans}) {
                    $stats->{$key}{$ans}++;
                } else {
                    $stats->{$key}{$ans} = 1;
                }
            } else {
    	    	if ($type =~ m/ESSAY/i) {
    	    	    $stats->{$key} = "";
    	    	    (length($ans) > 0) and
    	    	    	$stats->{$key} = $ans . "<BR><HR>";
        	} else { 
                    my %cnt = {};
                    $cnt{$ans} = 1;
                    $stats->{$key} = \%cnt;
    	    	}
            }
        };
        my $pr = $self->{'Test Header'}{'PR'};
        if (defined $tot->{$pr}) {
            $tot->{$pr}++;
        } else {
            $tot->{$pr} = 1;
        }
    }
}

1;
