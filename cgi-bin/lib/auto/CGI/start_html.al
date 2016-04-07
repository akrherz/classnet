# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub start_html {
    my($self,@p) = @_;
    my($title,$author,$base,$xbase,$script,@other) = 
        $self->rearrange([TITLE,AUTHOR,BASE,XBASE,SCRIPT],@p);

    # strangely enough, the title needs to be escaped as HTML
    # while the author needs to be escaped as a URL
    $title = $self->escapeHTML($title || 'Untitled Document');
    $author = $self->escapeHTML($author);
    my(@result);
    push(@result,"<HTML><HEAD><TITLE>$title</TITLE>");
    push(@result,"<LINK REV=MADE HREF=\"mailto:$author\">") if $author;
    push(@result,"<BASE HREF=\"http://".$self->server_name.":".$self->server_port.$self->script_name."\">")
        if $base && !$xbase;
    push(@result,"<BASE HREF=\"$xbase\">") if $xbase;
    push(@result,<<END) if $script;
<SCRIPT>
<!-- Hide script from HTML-compliant browsers
$script
// End script hiding. -->
</SCRIPT>
END
    ;
    push(@result,"</HEAD><BODY @other>");
    return join("\n",@result);
}

#### Method: end_html
# End an HTML document.
# Trivial method for completeness.  Just returns "</BODY>"
####
1;
