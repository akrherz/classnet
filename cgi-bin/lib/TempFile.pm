package TempFile;

$SL = $CGI::SL;
@TEMP=("${SL}tmp","${SL}usr${SL}tmp","${SL}var${SL}tmp","${SL}temp","${SL}Temporary Items");
foreach (@TEMP) {
    do {$TMPDIRECTORY = $_; last} if -w $_;
}
$TMPDIRECTORY  = "." unless $TMPDIRECTORY;
$SEQUENCE="CGItemp${$}0000";

%OVERLOAD = ('""'=>'as_string');

# Create a temporary file that will be automatically
# unlinked when finished.
# MACPERL users see the note below!
sub new {
    my($package) = @_;
    $SEQUENCE++;
    my $directory = "${TMPDIRECTORY}${SL}${SEQUENCE}";
    return $directory;
}

sub DESTROY {
    my($self) = @_;
    unlink $$self;              # get rid of the file
}

sub as_string {
    my($self) = @_;
    return $$self;
}

1;
