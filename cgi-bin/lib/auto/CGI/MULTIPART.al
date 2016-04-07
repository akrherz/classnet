# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub MULTIPART { 'multipart/form-data'; }

#### Method: keywords
# Keywords acts a bit differently.  Calling it in a list context
# returns the list of keywords.  
# Calling it in a scalar context gives you the size of the list.
####
1;
