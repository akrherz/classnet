# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub redirect {
    my($self,$url) = @_;
    $url = $url || $self->self_url;
    return join($CRLF,"Status: 302 Found",
                "Location: ${url}",
                "URI: <$url>",
                "Content-type: text/html"). # patches a bug in some servers
                    "${CRLF}${CRLF}";
}

#### Method: start_html
# Canned HTML header
#
# Parameters:
# $title -> (optional) The title for this HTML document (-title)
# $author -> (optional) e-mail address of the author (-author)
# $base -> (option) if set to true, will enter the BASE address of this document
#          for resolving relative references (-base) 
# $xbase -> (option) alternative base at some remote location (-xbase)
# $script -> (option) Javascript code (-script)
# @other -> (option) any other named parameters you'd like to incorporate into
#           the <BODY> tag.
####
1;
