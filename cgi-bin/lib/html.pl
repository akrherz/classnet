#!/usr/bin/perl
#
# html.pl	--- extract, normalize and hypertextify URLs in HTML files
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
# This package and friends can be found at:
# http://iamwww.unibe.ch/~scg/Src/
#
# This package contains:
#
# html'href:	identify URLs and turn them into hypertext links
# html'abs:	convert relative URLs to absolute ones
# html'parse:	parse an URL and return ($type,$host,$port,$path,$request)
# html'hrefs:	return all hrefs in a page
# html'esc:	escape characters in plain text

# BUGS: Craig Allen <ccount@mit.edu> points out that binary files
# that contain "<a" will be damaged by html'abs ...
# janl says: This is why html'abs should NOT be applied to anything but
#    html files.  w3mir don't anymore, neither should you.
# Abs got some bugs. 
# <base> references are NOT recognized by html'abs -- this needs
# to be fixed! ...

# &parse does not current handle firewall URLs

# &href can choke on "a...b" patterns

package html;
unshift(@INC,'/usr/local/lib/perl');

#v = 'html.pl v1.0'; # Oscar Nierstrasz 26/8/93
#v = 'html.pl v1.1'; # 15/01/94
	# -- fixed html'abs to handle HREFs without surrounding quotes
#v = 'html.pl v1.2'; # 09/02/94
	# -- fixed html'abs to handle images as well
#v = 'html.pl v1.3'; # 24/3/94
	# -- added hrefs (from `explore')
#v = 'html.pl v1.4'; # 25/3/94
	# -- fixed hrefs to handle malformed HREFs (missing or extra quotes)
#v = 'html.pl v1.5'; # 25/3/94
	# -- fixed abs to leave internal refs alone!
#v = 'html.pl v1.6'; # 25/3/94
	# -- moved to separate package
#v = 'html.pl v1.7'; # 13/4/94
	# -- repaired abs() to handle HREFs with missing quotes
#v = 'html.pl v1.8'; # 25/5/94
	# -- modified parse() to handle empty protocol type
#v = 'html.pl v1.9'; # 1/2/95 
	# -- fixed abs to search for closing ">"
#v = 'html.pl v1.10'; # 3/2/95 
	# -- fixed href() to use ^A as EOL placeholder (instead of #)
#v = 'html.pl v1.11'; # 20/2/95 Gorm Haug Eriksen <gorm@usit.uio.no>
	# -- fixed some bugs in abs
#v = 'html.pl v1.12'; # 8/7/95
	# -- added mailto: treatment (oscar) [may conflict with ftp formats?]
	# NEEDS further testing ...
#v = 'html.pl v1.13'; # 9/7/95
	# -- added &makequery
#v = 'html.pl v1.14'; # 16/8/95
	# -- fixed backslash handling in &makequery
#v = 'html.pl v1.15'; # 27/9/95
	# Nicolai Langfeldt (janl@ifi.uio.no)
	# 95/09/19 -- Added canonize function that makes a html doc a
	# bit more of of a SGML document.
#v = 'html.pl v1.16'; # 16/10/95 -- assume just 2-3 chars in country code (quinlan@charcoal.eg.bucknell.edu)
#v = 'html.pl v1.17'; # 1.11.95 -- also escape quotes in &makequery
#v = 'html.pl v1.18'; # 6.2.96 -- escape double quotes in &makequery
$v = 'html.pl v1.19'; # 7.2.96 -- accept "=" in html'href

# Try to recognize URLs and ftp file indentifiers and convert them into HREFs:
# This routine is evolving.  The patterns are not perfect.
# This is really a parsing problem, and not a job for perl ...
# It is also generally impossible to distinguish ftp site names
# from newsgroup names if the ":<directory>" is missing.
# An arbitrary file name ("runtime.pl") can also be confused.
sub href {
	# study; # doesn't speed things up ...

	# to avoid special cases for beginning & end of line
	s|^||; s|$||;

	# URLS: <serice>:<rest-of-url>
	s|(news:[\w.]+)|<a href="$&">$&</a>|g;
	s|(http:[\w/.:+=\-~#?]+)|<a href="$&">$&</a>|g;
	s|(file:[\w/.:+\-]+)|<a href="$&">$&</a>|g;
	s|(ftp:[\w/.:+\-]+)|<a href="$&">$&</a>|g;
	s|(wais:[\w/.:+\-]+)|<a href="$&">$&</a>|g;
	s|(gopher:[\w/.:+\-]+)|<a href="$&">$&</a>|g;
	s|(telnet:[\w/.:+\-]+)|<a href="$&">$&</a>|g;
	# s|(\w+://[\w/.:+\-]+)|<a href="$&">$&</a>|g;

	# catch some newsgroups to avoid confusion with sites:
	s|([^\w\-/.:@>])(alt\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(bionet\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(bit\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(comp\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(gnu\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(misc\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(news\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(rec\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;
	s|([^\w\-/.:@>])(ch\.[\w.+\-]+[\w+\-]+)|$1<a href="news:$2">$2</a>|g;

	# FTP locations (with directory):
	# anonymous@<site>:<path>
	s|(anonymous@)([a-zA-Z][\w.+\-]+\.[a-zA-Z]{2,}):(\s*)([\w\d+\-/.]+)|$1<a href="file://$2/$4">$2:$4</a>$3|g;
	# ftp@<site>:<path>
	s|(ftp@)([a-zA-Z][\w.+\-]+\.[a-zA-Z]{2,}):(\s*)([\w\d+\-/.]+)|$1<a href="file://$2/$4">$2:$4</a>$3|g;
	# <site>:<path>
	s|([^\w\-/.:@>])([a-zA-Z][\w.+\-]+\.[a-zA-Z]{2,}):(\s*)([\w\d+\-/.]+)|$1<a href="file://$2/$4">$2:$4</a>$3|g;
	# NB: don't confuse an http server with a port number for
	# an FTP location!
	# internet number version: <internet-num>:<path>
	s|([^\w\-/.:@])(\d{2,}\.\d{2,}\.\d+\.\d+):([\w\d+\-/.]+)|$1<a href="file://$2/$3">$2:$3</a>|g;

	# Mail addresses:
	# s|(\w+)@([a-zA-Z][\w.+\-]+\.[a-zA-Z]{2,})|<a href="mailto:$&">$&</a>|g;

	# just the site name (assume two dots, ends in .xx or .xxx): <site>
	s|([^\w\-/.:@>])([a-zA-Z][\w+\-]+\.[\w.+\-]+\.[a-zA-Z]{2,3})([^\w\d\-/.:!])|$1<a href="file://$2">$2</a>$3|g;

	# NB: can be confused with newsgroup names!
	# <site>.com has only one dot:
	s|([^\w\-/.:@>])([a-zA-Z][\w.+\-]+\.com)([^\w\-/.:])|$1<a href="file://$2">$2</a>$3|g;

	# just internet numbers:
	s|([^\w\-/.:@])(\d+\.\d+\.\d+\.\d+)([^\w\-/.:])|$1<a href="file://$2">$2</a>$3|g;
	# unfortunately inet numbers can easily be confused with
	# european telephone numbers ...

	s|^||; s|$||;
}

sub printa {
    @tmpbah = @_;
    foreach (@tmpbah) {
	print "-> $_\n";
    }
}

# convert relative http URLs to absolute ones:
# BUG: minor problem with binary files containing "<a" ...
# Not a bug, a binary file should not be submitted to this procedure
#
# A real bug.  http://www.interlog.com/foo is not synonymous to 
# http://www.interlog.com:80/foo according to this routine.
sub abs {
	local($url,$page) = @_;
	($type,$host,$port,$path,$request) = &parse(undef,undef,undef,undef,$url);
	$root = "http://$host:$port";
	@hrefs = split(/<[Aa]/,$page);
#        &printa(@hrefs);
#	exit(0);
	$n = 0;
	while (++$n <= $#hrefs) {
	 #   print "$hrefs[$n]\n";

		# absolute URLs ok:
#                ($hrefs[$n] =~ s|href\s*=\s*"?\s* 
		($hrefs[$n] =~ m|href\s*=\s*"?http://|i) && next;

		($hrefs[$n] =~ m|href\s*=\s*"?\w+:|i) && next;
		# internal refs ok:
		($hrefs[$n] =~ m|href\s*=\s*"?#|i) && next;
		# relative URL from root:
#                 ($hrefs[$n] =~ s|href\s*=\s*
		 ($hrefs[$n] =~ s|href\s*=\s*"?/([^">]*)"?|HREF="$root/$1"|i) && next;
                # this was changed, because it didn't manage urls with "'s in link
#		($hrefs[$n] =~ s|href\s*=\s*"?/([^">]*)(.*)"\s*>(.*)$|HREF="$root/$1"$2>$3|i) && next;
		# relative from $path:
#		# $hrefs[$n] =~ s|href\s*=\s*"?([^/"][^">]*)"?|HREF="$root$path$1"|i;
#		$hrefs[$n] =~ s|href\s*=\s*"?([^/"][^">]*)"?.*>|HREF="$root$path$1"|i;
                $hrefs[$n] =~ s|href\s*=\s*"?([^/"][^">]*)(.*)"\s*>(.*)|HREF="$root$path$1"$2>$3|i;
		# collapse relative paths:
		$hrefs[$n] =~ s|/\./|/|g;
		while ($hrefs[$n] =~ m|/\.\./|) {
			$hrefs[$n] =~ s|[^/]*/\.\./||;
		}
	}
	# Actually, this causes problems for binary files
	# that just happen to include the sequence "<a"!!!
	$page = join("<A",@hrefs);
	# duplicate code could be merged into a subroutine ...
	@hrefs = split(/<IMG/i,$page);
	$n = 0;
	while (++$n <= $#hrefs) {
		# absolute URLs ok:
		($hrefs[$n] =~ m|src\s*=\s*"?http://|i) && next;
		($hrefs[$n] =~ m|src\s*=\s*"?\w+:|i) && next;
		# relative URL from root:
		# ($hrefs[$n] =~ s|src\s*=\s*"?/([^">]*)"?|SRC="$root/$1"|i) && next;
		# ($hrefs[$n] =~ s|src\s*=\s*"?/([^"?>]*)"?(.*)>|SRC="$root/$1$2>"|i) && next;
		($hrefs[$n] =~ s|src\s*=\s*"?/([^"?>]*)"?(.*)>|SRC="$root/$1"$2>|i) && next;

		# relative from $path:
		# $hrefs[$n] =~ s|src\s*=\s*"?([^/"][^">]*)"?|SRC="$root$path$1"|i;
#		$hrefs[$n] =~ s|src\s*=\s*"?([^/"][^">]*)"?.*>|SRC="$root$path$1"|i;
$hrefs[$n] =~ s|src\s*=\s*"?([^/"][^">]*)"?\s+(.*)|SRC="$root$path$1" $2|i;
		# collapse relative paths:
		$hrefs[$n] =~ s|/\./|/|g;
		while ($hrefs[$n] =~ m|/\.\./|) {
			$hrefs[$n] =~ s|[^/]*/\.\./||;
		}
	}
	join("<IMG",@hrefs);
}

# convert an URL to ($type,host,port,path,request)
# given previous type, host, port and path, will handle relative URLs
# NB: May need special processing for different service types (e.g., news)
sub parse {
	local($type,$host,$port,$path,$url) = @_;

	# both type and ":" may be missing; could have multiple ":" ...
	if ($url =~ m|^(\w*):*//(.*)|) {
		$type = $1;
		if ($type eq "") { $type = "http"; }
		$host = $2;
		$port = &defport($type);
		$request = "/";	# default
		($host =~ s|^([^/]+)(/.*)$|$1|) && ($request = $2);
		($host =~ s/:(\d+)$//) && ($port = $1);
		($path = $request) =~ s|[^/]*$||;
	}
	else {
		# relative URL of form "<type>:<request>"
		if ($url =~ /^(\w+):+(.*)/) {
			$type = $1;
			$request = $2;
		}
		# relative URL of form "<request>"
		else { $request = $url; }
		$request =~ s|^$|/|;
		$request =~ s|^([^/])|$path$1|; # relative path
		$request =~ s|/\./|/|g;
		while ($request =~ m|/\.\./|) {
			$request =~ s|[^/]*/\.\./||;
		}
		# assume previous host & port:
		unless ($host) {
			# $! = "html'parse: no host for $url\n";
			return (undef,undef,undef,undef,undef);
		}
	}
	($type,$host,$port,$path,$request);
}

# default ports
sub defport {
	local($type) = @_;
	if ($type eq "http") { 80; }
	elsif ($type eq "gopher") { 70; }
	else { undef; }
}

# return a list of all the hrefs in a page
sub hrefs {
	local($page) = @_;
	$page =~ s/^[^<]+</</;
	$page =~ s/>[^<]*</></g;
	$page =~ s/>[^<]+$/>/;
	$page =~ s/<a[^>]*href\s*=\s*"?([^">]+)[^>]*>/$1\n/gi;
	$page =~ s/<img[^>]*src\s*=\s*"?([^">]+)[^>]*>/$1\n/gi;
	$page =~ s/<[^>]*>//g;
	$page =~ s/#.*//g;
	$page =~ s/\n+/\n/g;
	split(/\n/,$page);
}

# escape characters in plain text:
sub esc {
	s/&/&amp;/g;
	s/</&lt;/g;
	s/>/&gt;/g;
}

# escape special chars in a string so it can be used as an isindex query:
sub makequery {
	local($qry) = @_;
	$qry =~ s| |+|g; # escape blanks
		#qry =~ s|\\|\\\\|g; # escape backslashes
	$qry =~ s|\\|%5C%5C|g; # escape backslashes
		#qry =~ s|([()])|\\$1|g; # escape parens etc.
	$qry =~ s|([()'])|%5C$1|g; # escape parens, quotes etc.
	$qry =~ s|"|%22|g; # escape double quotes
	$qry;
}

sub canonize {
    # Canonize a nonconformant SGML (HTML) document to a more conformant
    # document, the general structure of a conformant document is:
    # <!SGML "ISO 8879:1986" ...>
    # <!DOCTYPE HTML ...>
    # <html>...</html>
    # We'll insert whatever is missing of those.  This allows automatic
    # type recognition of html files on disk, which is usefull, 
    # janl 95/09/19
    
    local($add)='';

    $add.='<!SGML "ISO 8879:1986">'."\n" 
	unless ($_[0] =~ m~<!SGML~i);
	
    $add.='<!DOCTYPE HTML SYSTEM "html.dtd">'."\n"
	unless $_[0] =~ m~<!DOCTYPE HTML~i;

    # If there are SGML headers but no <html>..</html> then we'll have
    # a problem (<html> will be outside the other SGML tags).
    # The right way to do it would be to extract and remove the SGML
    # tags, then insert everything in order.  But that would require
    # too much messy memory copies on a potentialy Very Large string.
    # But, it's very unlikely that someone will include the SGML tags
    # and then not include <html>...</html>
    $add.='<html>'."\n"	unless $_[0] =~ m~<HTML>~i;

    $_[0].="</html>\n" unless $_[0] =~ m~</HTML>~i;

    substr($_[0],0,0)=$add;
}

1;

