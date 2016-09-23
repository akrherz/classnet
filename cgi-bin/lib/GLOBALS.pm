package GLOBALS;

#########
=head1 GLOBALS

=head1 Global Variables:
$GLOBALS::SERVER_ROOT = 'https://classnet.geol.iastate.edu'
$GLOBALS::SERVER_LOG_DIR = '/local1/www/apache-isu/log'
$GLOBALS::CLASSNET_ROOT_DIR = '/local1/classnet'
$GLOBALS::ARCHIVE_ROOT_DIR = '/local2/archive'
$GLOBALS::SCRIPT_ROOT_DIR = '/local/classnet/cgi-bin'
$GLOBALS::SERVER_IMAGES = "$GLOBALS::SERVER_ROOT/gifs"
$GLOBALS::HELP_ROOT = "$GLOBALS::SERVER_ROOT/help"
$GLOBALS::SCRIPT_ROOT = "$GLOBALS::SERVER_ROOT/cgi-bin/cn_devel"
$GLOBALS::MAIL = "$GLOBALS::SERVER_ROOT/cgi-bin/mail"
$GLOBALS::ADMIN_EMAIL = 'akrherz@iastate.edu'
$GLOBALS::SYSTEM_EMAIL = 'akrherz@iastate.edu'
$GLOBALS::FORUM_ROOT = "$GLOBALS::SERVER_ROOT/cgi-bin/netforum2"
$GLOBALS::FORUM_DIR = '/local/classnet/cgi-bin/netforum2'
$GLOBALS::TICKET_DIR = '/local1/tickets'

$GLOBALS::ASSIGNMENT_TYPES = 'TEST,FORECAST,INCLASS,EVAL,DIALOG'
$GLOBALS::MAX_CLASS = 100
$GLOBALS::MAX_STUDENTS = 1000
$GLOBALS::HR = '<HR SIZE=4>'
$GLOBALS::BACKGROUND = "BACKGROUND=\"$GLOBALS::SERVER_IMAGES/back.gif\""
$GLOBALS::BGCOLOR = 'BGCOLOR=#b2b07a' 
$GLOBALS::RED_BALL =
 "<IMG SRC=$SERVER_IMAGES/red.gif WIDTH=14 HEIGHT=14 ALIGN=BOTTOM 
ALT=\"Red Bullet\">"

=cut
##########

$SRM_ALIAS = '';
$SERVER_ROOT = 'https://classnet.geol.iastate.edu';
$SECURE_ROOT = 'https://classnet.geol.iastate.edu';
$SERVER_LOG_DIR = '/local/classnet/data/logs';
$CLASSNET_ROOT_DIR = "/local/classnet/data";
$ARCHIVE_ROOT_DIR = "/local/classnet/archive";
#$SCRIPT_ROOT_DIR = "/local1/www/apache-isu/cgi-bin/cn_devel";
$SCRIPT_ROOT_DIR = "/local/classnet/cgi-bin";
$SERVER_IMAGES = "/gifs";
$HELP_ROOT = "$SERVER_ROOT/help";
#$SCRIPT_ROOT = "$SERVER_ROOT/cgi-bin/cn_devel";
$SCRIPT_ROOT = "$SECURE_ROOT/cgi-bin";
$SECURE_SCRIPT_ROOT = "$SECURE_ROOT/cgi-bin";
$TICKET_DIR = '/local/classnet/data/tickets/';

$MAIL = "$SERVER_ROOT/cgi-bin/mail";
$FORUM_ROOT = "$SERVER_ROOT/cgi-bin/netforum2";
$FORUM_DIR = '/local/classnet/cgi-bin/netforum2';
$ADMIN_EMAIL = 'akrherz@iastate.edu';
$SYSTEM_EMAIL = 'akrherz@iastate.edu';
$TEST_EMAIL = 'akrherz@iastate.edu';
$ASSIGNMENT_TYPES = 'TEST,FORECAST,INCLASS,EVAL,DIALOG';
$MAX_CLASS = 300;
$MAX_STUDENTS = 1000;
$MAX_ANS_LENGTH = 32768;

$HR = '<HR SIZE=4>';
$BACKGROUND = "BACKGROUND=\"$GLOBALS::SERVER_IMAGES/ypaper.gif\"";
# color for yellow paper
$BGCOLOR = 'BGCOLOR=#e3d3ad';
# color for green marble
#$BGCOLOR = 'BGCOLOR=#b2b07a';
# color weave yellow
#$BGCOLOR = 'BGCOLOR=#d1a85c';
$RED_BALL = "<IMG SRC=$SERVER_IMAGES/red.gif WIDTH=14 HEIGHT=14 
ALIGN=BOTTOM ALT=\"Red Bullet\"> ";


1;










