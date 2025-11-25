#! /usr/local/bin/perl
#
# http.pl	--- retrieve http URLs
#
# Copyright (c) 1995 Oscar Nierstrasz
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program (as the file COPYING in the main directory of
# the distribution); if not, write to the Free Software Foundation,
# Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# 
# NB: If this package interests you, you should probably
# have a look at Roy Fielding's libwww-perl packages:
# http://www.ics.uci.edu/WebSoft/libwww-perl/
#
# oscar :
# http'get:	perform an http request and return the result
#
# gorm :
# http'mod_get   perform an http request with the modified-since req.
# http'get_last_modified  return the last modified stamp on a file in
#                         the right format for use with http
# http'bit2rfc850  convert from 32 bit timestamp to rfc850
#
# This package and friends can be found at:
# http://iamwww.unibe.ch/~scg/Src/
#
# Oscar Nierstrasz 26/8/93
# Gorm Haug Eriksen gorm@usit.uio.no
#
# oscar 25/3/94 -- moved to separate package
# oscar 28/3/94 -- added stripping of MIME headers (code by Martijn Koster)
#
# FIX to strip off MIME headers!
# oscar 9/1/95  -- added Accept-Header field; accepts every mime type; 
#
# gorm 20/5/95 -- added some procedures for Modified-Since get, and
#                 for handeling. this procedure will be used in w3mir.pl 
# gorm 21/5/95 -- added redirection in http'mod_get
# TEMPORARY HACK!

package http;

unshift(@INC,'/usr/local/lib/perl');
    

# This should be installed in /local/lib/perl
# If it's not there, complain to your system admin!
require "sys/socket.ph";


$timeout = 60;

$sockaddr = 'S n a4 x8';
chop($thishost = `hostname`);
chop($user = `whoami`);
($name, $aliases, $proto) = getprotobyname("tcp");
($name, $aliases, $type, $len, $thisaddr) = gethostbyname($thishost);
$thissock = pack($sockaddr, &AF_INET, 0, $thisaddr);

$useragent  = "User-Agent: w3mirror\r\n";
$from       = "From: $user@$thishost\r\n";
$mimeaccept = "Accept: */*\r\n";     #-- accept any mime type


# perform an http request and return the result
# Code adapted from Marc van Heyningen
sub get {
    local($host,$port,$request,$version) = @_;
    ($fqdn, $aliases, $type, $len, $thataddr) = gethostbyname($host);
    $that = pack($sockaddr, &AF_INET, $port, $thataddr);
    socket(FS, &AF_INET, &SOCK_STREAM, $proto) || return undef;
    bind(FS, $thissock) || return undef;
    local($/);
    unless (eval q!
        $SIG{'ALRM'} = "http'timeout";
        alarm($timeout);
        connect(FS, $that) || return undef;
        select(FS); $| = 1; select(STDOUT);
	# MIME header treatment from Martijn Koster
        if ($version) {
            print FS "GET $request HTTP/1.0\r\n$useragent$from$mimeaccept\r\n"; 
            undef($page);
            $/ = "\n";
            $_ = <FS>;
            if (m:HTTP/1.0\s+\d+\s+:) { #HTTP/1.0
                while(<FS>) {
                    last if /^[\r\n]+$/; # end of header
                }
                undef($/);
                $page = <FS>;
            }
            else {    # old style server reply
                undef($/);
                $page = $_;
                $_ = <FS>;            
                $page .= $_;
            }
        }
        else {        # old style request
            print FS "GET $request\r\n";
            $page = <FS>; # gives old-style reqply
        }
        $SIG{'ALRM'} = "IGNORE";
        !) {
            return undef;
        }
    close(FS);
    $page;
}

sub get_last_modified {
# will return the last modified time for a local file
# this procedure are for mirroring. The return will be in the
# rfc 850 format, and the timezone will be GMT
    local($file) = @_;
    local(@tmp) = stat($file); # file doesn't exist ok to fetch
    # now we got the last modified in a 32 bit integer.
    # time to convert it and return
    return &bit2rfc850($tmp[9]);
}
    
sub bit2rfc850 {
# this procedure will convert a 32bit timefield to regular
# rfc850 GMT format. this is implemented in this package because
# this format is the format used by http
# IN  : 32bit timesign
# OUT : http formated timestamp
    local($timebit) = @_;
    local(@DoW) = ('Sunday','Monday','Tuesday','Wedensday','Thursday','Friday','Saturday');
    local(@MoY) = ('Jan','Feb','Mar','Apr','May','Jun',
	    'Jul','Aug','Sep','Oct','Nov','Dec'); 

    local($time) = @_;
    local($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);
    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = 
	gmtime($timebit);	# uses GMT time
# hack to fix the real time #########################################
    @tmplist = ($mday,$hour,$min,$sec);                             #
    for ($c=0;$c <= $#tmplist;$c++) {                               #
	$tmplist[$c] = "0$tmplist[$c]" if $tmplist[$c] < 10;        #
    }				                                    #
    ($mday,$hour,$min,$sec) = @tmplist;                             #
#####################################################################
# returning the right http format	
    sprintf("%s, %s-%s-%s %s:%s:%s GMT", 
	    $DoW[$wday], $mday, $MoY[$mon], $year, $hour, $min, $sec)
}

sub mod_get {
# this is a patched version of the above get, that will use 
# a timestamp to check if it will get he page or not.
# if it doesn't get the page, it will thought still recive
# the header of the file. this was added by gorm haug eriksen
# gorm@usit.uio.no for use in a mirror (W3) script
    local($host,$port,$request,@modtime) = @_;
    !@modtime && die "get_mod: didnt' get a lastmodified argument";
    # modtime is a list on the rfc850 format, that is :
    # Weekday, DD-Mon-YY HH:MM:SS TIMEZONE, but the httpd 
    # protocoll state that the TIMEZONE to be used always 
    # should be GMT. 
    ($fqdn, $aliases, $type, $len, $thataddr) = gethostbyname($host);
    $that = pack($sockaddr, &AF_INET, $port, $thataddr);
    socket(FS, &AF_INET, &SOCK_STREAM, $proto) || return undef;
    bind(FS, $thissock) || return undef;
    local($/);
    unless (eval q!
	    $SIG{'ALRM'} = "http'timeout";
	    alarm($timeout);
	    connect(FS, $that) || return undef;
	    select(FS); $| = 1; select(STDOUT);
	    # MIME header treatment from Martijn Koster
	    print FS "GET $request HTTP/1.0\r\n${useragent}${from}${mimeaccept}If-Modified-Since: @modtime\r\n\r\n"; 
# debug
#	    print "GET $request HTTP/1.0\r\n${useragent}${from}${mimeaccept}If-Modified-Since: @modtime\r\n\r\n"; 

	    undef($page);
	    $/ = "\n";
	    $_ = <FS>;
	    if (m:HTTP/1.0\s+(\d+)\s+:) { #HTTP/1.0
# DEBUG :      	print "Return $1\n";
		if ($1 eq "302") {
		    # this is a routine that will enable redirection
		    # in the program. It will fetch the new url, and 
		    # the user will see nothing to the redirection
		    close(FS);
		    print "$that\n";
		    alarm(0);	# stopping alarm
		    $SIG{'ALRM'} = "http'timeout";
		    alarm($timeout);
		    ($fqdn, $aliases, $type, $len, $thataddr) = gethostbyname($host);
		    $that = pack($sockaddr, &AF_INET, $port, $thataddr);
		    socket(FS, &AF_INET, &SOCK_STREAM, $proto) || return undef;
		    bind(FS, $thissock) || return undef;
		    connect(FS, $that) || return undef;
		    select(FS); $| = 1; select(STDOUT);
		    # MIME header treatment from Martijn Koster
		    $request = "$request/index.html";
		    print "REQ : $request\n";
		    print FS "GET $request HTTP/1.0\r\n${useragent}${from}${mimeaccept}If-Modified-Since: @modtime\r\n\r\n"; 
		    undef $page;
		}
		    return undef if $1 == 403; # not modified
		while(<FS>) {
		    last if /^[\r\n]+$/; # end of header
		}
		undef($/);
		$page = <FS>;
	    }
	    else {			# old style server reply
		warn "Old Style Server Reply from $host. Ask admin to upgrade server or forget to mirror it" && return undef;
	    }
	    
	    $SIG{'ALRM'} = "IGNORE";
        !) {
            return undef; # a error has occoured
        }
    close(FS);
    $page;
}

sub timeout { die "Timeout\n"; }

1;

