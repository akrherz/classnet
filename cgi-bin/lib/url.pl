#! /usr/bin/perl
#
# url.pl	--- recognize, parse and retrieve URLs
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
#
# NB: If this package interests you, you should probably
# have a look at Roy Fielding's libwww-perl packages:
# http://www.ics.uci.edu/WebSoft/libwww-perl/
#
# This package and friends can be found at:
# http://iamwww.unibe.ch/~scg/Src/
#
# This package contains:
#
# url'get:	parse an URL and perform an http get
# url'do_ftp:	perform an ftp request and return the result
#
# Oscar Nierstrasz 26/8/93
#
# 25/3/94 -- moved subroutines into packages `http' and `html'
# 5/4/94 -- commented out ftp stuff (problems at various sites)

# Gorm Haug Eriksen gorm@usit.uio.no
# 20/5/95 -- added get_mod 

package url;

# Where to find libraries:
unshift(@INC,'/usr/lib/perl');

# Gene Spafford's ftp package (and using the chat package).
# Added ftp'grab -- a variant of ftp'get that returns its result
# rather than writing to a local file.
# Get this from a perl archive ...
# require "ftplib.pl";
require "http.pl";
require "html.pl";

# Should be replaced ...
# require "gopher.pl";

# parse an URL, issue the request and return the result
sub get {
	local($url,$version) = @_;
	($type,$host,$port,$path,$request) =
		html'parse($type,$host,$port,$path,$url);
	if ($host) {
		if ($type eq "http") { 
                   my $txt=  http'get($host,$port,$request,$version); 
                } else { 
                    undef; 
                }
	} else {
            undef;
	}
}

sub mod_get {
    # this is the same as the above, unly that it checks the time
    # before it fetch the url
    local($url,@modtime) = @_;
    ($type,$host,$port,$path,$request) = &html'parse($type,$host,$port,$path,$url);
	 if ($host) {
             $bah= &http'mod_get($host,$port,$request,@modtime); 
    
    $bah;
    }
}

# default ports
sub defport {
	local($type) = @_;
	if ($type eq "http") { 80; }
	elsif ($type eq "gopher") { 70; }
	else { undef; }
}

# ftp'grab is a version of ftp'get that returns the page
# retrieved rather than writing it to a local file.
# Perhaps not so nice for big files, but what the heck.
# sub do_ftp {
# 	local($host,$file) = @_;
# 	&ftp'open($host, "ftp", "$user@$thishost") || &fail;
# 	&ftp'type("i") || &fail;
# 	$page = &ftp'grab($file) || &fail;
# 	&ftp'close;
# 	$page;
# }
# 
# sub fail {
# 	$save = &ftp'error;
# 	&ftp'close;
# 	die $save;
# }

1;



