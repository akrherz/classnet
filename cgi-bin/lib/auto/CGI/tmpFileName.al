# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub tmpFileName {
    my($self,$filename) = @_;
    return $self->{'.tmpfiles'}->{$filename};
}

# so that require() returns true and to prevent
# warnings with the -w switch;
$CGI::revision || 1; 

__END__

=head1 NAME

CGI - Simple Common Gateway Interface Class

=head1 ABSTRACT

This perl library uses perl5 objects to make it easy to create
Web fill-out forms and parse their contents.  This package
defines CGI objects, entities that contain the values of the
current query string and other state variables.
Using a CGI object's methods, you can examine keywords and parameters
passed to your script, and create forms whose initial values
are taken from the current query (thereby preserving state
information).

The current version of CGI.pm is available at

  http://www-genome.wi.mit.edu/ftp/pub/software/WWW/cgi_docs.html
  ftp://ftp-genome.wi.mit.edu/pub/software/WWW/

=head1 INSTALLATION:

To install this package, just change to the directory in which this
file is found and type the following:

        perl Makefile.PL
        make
        make install

This will copy CGI.pm to your perl library directory for use by all
perl scripts.  You probably must be root to do this.   Now you can
load the CGI routines in your Perl scripts with the line:

        use CGI;

If you don't have sufficient privileges to install CGI.pm in the Perl
library directory, you can put CGI.pm into some convenient spot, such
as your home directory, or in cgi-bin itself and prefix all Perl
scripts that call it with something along the lines of the following
preamble:

        BEGIN {
                unshift(@INC,'/home/davis/lib');
        }
        use CGI;

The CGI distribution also comes with a cute module called L<CGI::Carp>.
It redefines the die(), warn(), confess() and croak() error routines
so that they write nicely formatted error messages into the server's
error log (or to the output stream of your choice).  This avoids long
hours of groping through the error and access logs, trying to figure
out which CGI script is generating fatal error messages.

=head1 DESCRIPTION

=head2 CREATING A NEW QUERY OBJECT:

     $query = new CGI

This will parse the input (from both POST and GET methods) and store
it into a perl5 object called $query.  

=head2 CREATING A NEW QUERY OBJECT FROM AN INPUT FILE

     $query = new CGI(INPUTFILE)

If you provide a file handle to the new() method, it
will read parameters from the file (or STDIN, or whatever).  The
file can be in any of the forms describing below under debugging
(i.e. a series of newline delimited TAG=VALUE pairs will work).
Conveniently, this type of file is created by the save() method
(see below).

=head2 FETCHING A LIST OF KEYWORDS FROM THE QUERY:

     @keywords = $query->keywords

If the script was invoked as the result of an <ISINDEX> search, the
parsed keywords can be obtained as an array using the keywords() method.

=head2 FETCHING THE NAMES OF ALL THE PARAMETERS PASSED TO YOUR SCRIPT:

     @names = $query->param

If the script was invoked with a parameter list
(e.g. "name1=value1&name2=value2&name3=value3"), the param()
method will return the parameter names as a list.  If the
script was invoked as an <ISINDEX> script, there will be a
single parameter named 'keywords'.

NOTE: As of version 1.5, the array of parameter names returned will
be in the same order as they were submitted by the browser.
Usually this order is the same as the order in which the 
parameters are defined in the form (however, this isn't part
of the spec, and so isn't guaranteed).

=head2 FETCHING THE VALUE OR VALUES OF A SINGLE NAMED PARAMETER:

    @values = $query->param('foo');

              -or-

    $value = $query->param('foo');

Pass the param() method a single argument to fetch the value of the
named parameter. If the parameter is multivalued (e.g. from multiple
selections in a scrolling list), you can ask to receive an array.  Otherwise
the method will return a single value.

=head2 SETTING THE VALUE(S) OF A NAMED PARAMETER:

    $query->param('foo','an','array','of','values');

This sets the value for the named parameter 'foo' to an array of
values.  This is one way to change the value of a field AFTER
the script has been invoked once before.  (Another way is with
the -override parameter accepted by all methods that generate
form elements.)

param() also recognizes a named parameter style of calling described
in more detail later:

    $query->param(-name=>'foo',-values=>['an','array','of','values']);

                              -or-

    $query->param(-name=>'foo',-value=>'the value');

=head2 IMPORTING ALL PARAMETERS INTO A NAMESPACE:

   $query->import_names('R');

This creates a series of variables in the 'R' namespace.  For example,
$R::foo, @R:foo.  For keyword lists, a variable @R::keywords will appear.
If no namespace is given, this method will assume 'Q'.
WARNING:  don't import anything into 'main'; this is a major security
risk!!!!

In older versions, this method was called import().  While the old name
is maintained for compatability, use import_names() for consistency with
the CGI:: modules.

=head2 DELETING A PARAMETER COMPLETELY:

    $query->delete('foo');

This completely clears a parameter.  It sometimes useful for
resetting parameters that you don't want passed down between
script invocations.

=head2 SAVING THE STATE OF THE FORM TO A FILE:

    $query->save(FILEHANDLE)

This will write the current state of the form to the provided
filehandle.  You can read it back in by providing a filehandle
to the new() method.  Note that the filehandle can be a file, a pipe,
or whatever!

=head2 CREATING A SELF-REFERENCING URL THAT PRESERVES STATE INFORMATION:

    $myself = $query->self_url;
    print "<A HREF=$myself>I'm talking to myself.</A>";

self_url() will return a URL, that, when selected, will reinvoke
this script with all its state information intact.  This is most
useful when you want to jump around within the document using
internal anchors but you don't want to disrupt the current contents
of the form(s).  Something like this will do the trick.

     $myself = $query->self_url;
     print "<A HREF=$myself#table1>See table 1</A>";
     print "<A HREF=$myself#table2>See table 2</A>";
     print "<A HREF=$myself#yourself>See for yourself</A>";

If you don't want to get the whole query string, call
the method url() to return just the URL for the script:

    $myself = $query->url;
    print "<A HREF=$myself>No query string in this baby!</A>\n";

You can also retrieve the unprocessed query string with query_string():

    $the_string = $query->query_string;

=head2 COMPATABILITY WITH CGI-LIB.PL

To make it easier to port existing programs that use cgi-lib.pl
the compatability routine "ReadParse" is provided.  Porting is
simple:

OLD VERSION
    require "cgi-lib.pl";
    &ReadParse;
    print "The value of the antique is $in{antique}.\n";

NEW VERSION
    use CGI;
    CGI::ReadParse
    print "The value of the antique is $in{antique}.\n";

CGI.pm's ReadParse() routine creates a tied variable named %in,
which can be accessed to obtain the query variables.  Like
ReadParse, you can also provide your own variable.  Infrequently
used features of ReadParse, such as the creation of @in and $in 
variables, are not supported.

Once you use ReadParse, you can retrieve the query object itself
this way:

    $q = $in{CGI};
    print $q->textfield(-name=>'wow',
                        -value=>'does this really work?');

This allows you to start using the more interesting features
of CGI.pm without rewriting your old scripts from scratch.

=head2 CALLING CGI FUNCTIONS THAT TAKE MULTIPLE ARGUMENTS

In versions of CGI.pm prior to 2.0, it could get difficult to remember
the proper order of arguments in CGI function calls that accepted five
or six different arguments.  As of 2.0, there's a better way to pass
arguments to the various CGI functions.  In this style, you pass a
series of name=>argument pairs, like this:

   $field = $query->radio_group(-name=>'OS',
                                -values=>[Unix,Windows,Macintosh],
                                -default=>'Unix');

The advantages of this style are that you don't have to remember the
exact order of the arguments, and if you leave out a parameter, in
most cases it will default to some reasonable value.  If you provide
a parameter that the method doesn't recognize, it will usually do
something useful with it, such as incorporating it into the HTML form
tag.  For example if Netscape decides next week to add a new
JUSTIFICATION parameter to the text field tags, you can start using
the feature without waiting for a new version of CGI.pm:

   $field = $query->textfield(-name=>'State',
                              -default=>'gaseous',
                              -justification=>'RIGHT');

This will result in an HTML tag that looks like this:

        <INPUT TYPE="textfield" NAME="State" VALUE="gaseous"
               JUSTIFICATION="RIGHT">

Parameter names are case insensitive: you can use -name, or -Name or
-NAME.  You don't have to use the hyphen if you don't want to.  After
creating a CGI object, call the B<use_named_parameters()> method with
a nonzero value.  This will tell CGI.pm that you intend to use named
parameters exclusively:

   $query = new CGI;
   $query->use_named_parameters(1);
   $field = $query->radio_group('name'=>'OS',
                                'values'=>['Unix','Windows','Macintosh'],
                                'default'=>'Unix');

Actually, CGI.pm only looks for a hyphen in the first parameter.  So
you can leave it off subsequent parameters if you like.  Something to
be wary of is the potential that a string constant like "values" will
collide with a keyword (and in fact it does!) While Perl usually
figures out when you're referring to a function and when you're
referring to a string, you probably should put quotation marks around
all string constants just to play it safe.

=head2 CREATING THE HTTP HEADER:

        print $query->header;

             -or-

        print $query->header('image/gif');

             -or-

        print $query->header('text/html','204 No response');

             -or-

        print $query->header(-type=>'image/gif',
                             -status=>'402 Payment required',
                             -expires=>'+3d',
                             -cookie=>$cookie,
                             -Cost=>'$2.00');

header() returns the Content-type: header.  You can provide your own
MIME type if you choose, otherwise it defaults to text/html.  An
optional second paramer specifies the status code and a human-readable
message.  For example, you can specify 204, "No response" to create a
script that tells the browser to do nothing at all.  If you want to
add additional fields to the header, just tack them on to the end:

    print $query->header('text/html','200 OK','Content-Length: 3002');

The last example shows the named argument style for passing arguments
to the CGI methods using named parameters.  Recognized parameters are
B<-type>, B<-status>, B<-expires>, and B<-cookie>.  Any other 
parameters will be stripped of their initial hyphens and turned into
header fields, allowing you to specify any HTTP header you desire.

Most browsers will not cache the output from CGI scripts.  Every time
the browser reloads the page, the script is invoked anew.  You can
change this behavior with the B<-expires> parameter.  When you specify
an absolute or relative expiration interval with this parameter, some
browsers and proxy servers will cache the script's output until the
indicated expiration date.  The following forms are all valid for the
-expires field:

        +30s                              30 seconds from now
        +10m                              ten minutes from now
        +1h                               one hour from now
        -1d                               yesterday (i.e. "ASAP!")
        now                               immediately
        +3M                               in three months
        +10y                              in ten years time
        Thursday, 25-Apr-96 00:40:33 GMT  at the indicated time & date

(CGI::expires() is the static function call used internally that turns
relative time intervals into HTTP dates.  You can call it directly if
you wish.)

The B<-cookie> parameter generates a header that tells the browser to provide
a "magic cookie" during all subsequent transactions with your script.
Netscape cookies have a special format that includes interesting attributes
such as expiration time.  Use the cookie() method to create and retrieve
session cookies.

As of version 1.56, all HTTP headers produced by CGI.pm contain the
Pragma: no-cache instruction.  However, as of version 1.57, this is
turned OFF by default because it causes Netscape 2.0 and higher to
produce an annoying warning message every time the "back" button is
hit.  Turn it on again with the method cache().

=head2 GENERATING A REDIRECTION INSTRUCTION

   print $query->redirect('http://somewhere.else/in/movie/land');

redirects the browser elsewhere.  If you use redirection like this,
you should B<not> print out a header as well.  As of version 2.0, we
produce both the unofficial Location: header and the official URI:
header.  This should satisfy most servers and browsers.

One hint I can offer is that relative links may not work correctly
when when you generate a redirection to another document on your site.
This is due to a well-intentioned optimization that some servers use.
The solution to this is to use the full URL (including the http: part)
of the document you are redirecting to.

=head2 CREATING THE HTML HEADER:

   print $query->start_html(-title=>'Secrets of the Pyramids',
                            -author=>'fred@capricorn.org',
                            -base=>'true',
                            -BGCOLOR=>"#00A0A0"');

   -or-

   print $query->start_html('Secrets of the Pyramids',
                            'fred@capricorn.org','true',
                            'BGCOLOR="#00A0A0"');

This will return a canned HTML header and the opening <BODY> tag.  
All parameters are optional.   In the named parameter form, recognized
parameters are -title, -author and -base (see below for the
explanation).  Any additional parameters you provide, such as the
Netscape unofficial BGCOLOR attribute, are added to the <BODY> tag.

Version 2.16 adds the argument -xbase, which you can use to provide
an HREF for the <BASE> tag different from the current location, as
in

    -xbase=>"http://home.mcom.com/"

JAVASCRIPTING:  Version 2.17 adds the B<-script>, B<-onLoad> and 
B<-onUnload> parameters, 
which are used to add Netscape JavaScript calls to your pages.  
B<-script> should point to a block of
text containing JavaScript function definitions.  This block will be
placed within a <SCRIPT> block inside the HTML (not HTTP) header.  The
block is placed in the header in order to give your page a fighting 
chance of having all its JavaScript functions in place even if the user
presses the stop button before the page has loaded completely.  CGI.pm
attempts to format the script in such a way that JavaScript-naive
browsers will not choke on the code: unfortunately there are some browsers,
such as Chimera for Unix, that get confused by it nevertheless.

The B<-onLoad> and B<-onUnload> parameters point to fragments of JavaScript
code to execute when the page is respectively opened and closed by the
browser.  Usually these parameters are calls to functions defined in the
B<-script> field:

      $query = new CGI;
      print $query->header;
      $JSCRIPT=<<END;
      // Ask a silly question
      function riddle_me_this() {
         var r = prompt("What walks on four legs in the morning, " +
                       "two legs in the afternoon, " +
                       "and three legs in the evening?");
         response(r);
      }
      // Get a silly answer
      function response(answer) {
         if (answer == "man")
            alert("Right you are!");
         else
            alert("Wrong!  Guess again.");
      }
      END
      print $query->start_html(-title=>'The Riddle of the Sphinx',
                               -script=>$JSCRIPT);

See

   http://home.netscape.com/eng/mozilla/2.0/handbook/javascript/

for more information about JavaScript.

The old-style positional parameters are as follows:

=over 4

=item B<Parameters:>

=item 1.

The title

=item 2.

The author's e-mail address (will create a <LINK REV="MADE"> tag if present

=item 3.

A 'true' flag if you want to include a <BASE> tag in the header.  This
helps resolve relative addresses to absolute ones when the document is moved, 
but makes the document hierarchy non-portable.  Use with care!

=item 4, 5, 6...

Any other parameters you want to include in the <BODY> tag.  This is a good
place to put Netscape extensions, such as colors and wallpaper patterns.

=back

=head2 ENDING THE HTML DOCUMENT:

        print $query->end_html

This ends an HTML document by printing the </BODY></HTML> tags.

=head1 CREATING FORMS:

I<General note>  The various form-creating methods all return strings
to the caller, containing the tag or tags that will create the requested
form element.  You are responsible for actually printing out these strings.
It's set up this way so that you can place formatting tags
around the form elements.

I<Another note> The default values that you specify for the forms are only
used the B<first> time the script is invoked (when there is no query
string).  On subsequent invocations of the script (when there is a query
string), the former values are used even if they are blank.  

If you want to change the value of a field from its previous value, you have two
choices:

(1) call the param() method to set it.

(2) use the -override (alias -force) parameter (a new feature in version 2.15).
This forces the default value to be used, regardless of the previous value:

   print $query->textfield(-name=>'field_name',
                           -default=>'starting value',
                           -override=>1,
                           -size=>50,
                           -maxlength=>80);

I<Yet another note> By default, the text and labels of form elements are
escaped according to HTML rules.  This means that you can safely use
"<CLICK ME>" as the label for a button.  However, it also interferes with
your ability to incorporate special HTML character sequences, such as &Aacute;,
into your fields.  If you wish to turn off automatic escaping, call the
autoEscape() method with a false value immediately after creating the CGI object:

   $query = new CGI;
   $query->autoEscape(undef);
                             

=head2 CREATING AN ISINDEX TAG

   print $query->isindex(-action=>$action);

         -or-

   print $query->isindex($action);

Prints out an <ISINDEX> tag.  Not very exciting.  The parameter
-action specifies the URL of the script to process the query.  The
default is to process the query with the current script.

=head2 STARTING AND ENDING A FORM

    print $query->startform(-method=>$method,
                            -action=>$action,
                            -encoding=>$encoding);
      <... various form stuff ...>
    print $query->endform;

        -or-

    print $query->startform($method,$action,$encoding);
      <... various form stuff ...>
    print $query->endform;

startform() will return a <FORM> tag with the optional method,
action and form encoding that you specify.  The defaults are:
        
    method: POST
    action: this script
    encoding: application/x-www-form-urlencoded

endform() returns the closing </FORM> tag.  

Startform()'s encoding method tells the browser how to package the various
fields of the form before sending the form to the server.  Two
values are possible:

=over 4

=item B<application/x-www-form-urlencoded>

This is the older type of encoding used by all browsers prior to
Netscape 2.0.  It is compatible with many CGI scripts and is
suitable for short fields containing text data.  For your
convenience, CGI.pm stores the name of this encoding
type in B<$CGI::URL_ENCODED>.

=item B<multipart/form-data>

This is the newer type of encoding introduced by Netscape 2.0.
It is suitable for forms that contain very large fields or that
are intended for transferring binary data.  Most importantly,
it enables the "file upload" feature of Netscape 2.0 forms.  For
your convenience, CGI.pm stores the name of this encoding type
in B<$CGI::MULTIPART>

Forms that use this type of encoding are not easily interpreted
by CGI scripts unless they use CGI.pm or another library designed
to handle them.

=back

For compatability, the startform() method uses the older form of
encoding by default.  If you want to use the newer form of encoding
by default, you can call B<start_multipart_form()> instead of
B<startform()>.

JAVASCRIPTING: The B<-name> and B<-onSubmit> parameters are provided
for use with JavaScript.  The -name parameter gives the
form a name so that it can be identified and manipulated by
JavaScript functions.  -onSubmit should point to a JavaScript
function that will be executed just before the form is submitted to your
server.  You can use this opportunity to check the contents of the form 
for consistency and completeness.  If you find something wrong, you
can put up an alert box or maybe fix things up yourself.  You can 
abort the submission by returning false from this function.  

Usually the bulk of JavaScript functions are defined in a <SCRIPT>
block in the HTML header and -onSubmit points to one of these function
call.  See start_html() for details.

=head2 CREATING A TEXT FIELD

    print $query->textfield(-name=>'field_name',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80);
        -or-

    print $query->textfield('field_name','starting value',50,80);

textfield() will return a text input field.  

=over 4

=item B<Parameters>

=item 1.

The first parameter is the required name for the field (-name).  

=item 2.

The optional second parameter is the default starting value for the field
contents (-default).  

=item 3.

The optional third parameter is the size of the field in
      characters (-size).

=item 4.

The optional fourth parameter is the maximum number of characters the
      field will accept (-maxlength).

=back

As with all these methods, the field will be initialized with its 
previous contents from earlier invocations of the script.
When the form is processed, the value of the text field can be
retrieved with:

       $value = $query->param('foo');

If you want to reset it from its initial value after the script has been
called once, you can do so like this:

       $query->param('foo',"I'm taking over this value!");

NEW AS OF VERSION 2.15: If you don't want the field to take on its previous
value, you can force its current value by using the -override (alias -force)
parameter:

    print $query->textfield(-name=>'field_name',
                            -default=>'starting value',
                            -override=>1,
                            -size=>50,
                            -maxlength=>80);

JAVASCRIPTING: You can also provide B<-onChange>, B<-onFocus>, B<-onBlur>
and B<-onSelect> parameters to register JavaScript event handlers.
The onChange handler will be called whenever the user changes the
contents of the text field.  You can do text validation if you like.
onFocus and onBlur are called respectively when the insertion point
moves into and out of the text field.  onSelect is called when the
user changes the portion of the text that is selected.

=head2 CREATING A BIG TEXT FIELD

   print $query->textarea(-name=>'foo',
                          -default=>'starting value',
                          -rows=>10,
                          -columns=>50);

        -or

   print $query->textarea('foo','starting value',10,50);

textarea() is just like textfield, but it allows you to specify
rows and columns for a multiline text entry box.  You can provide
a starting value for the field, which can be long and contain
multiple lines.

JAVASCRIPTING: The B<-onChange>, B<-onFocus>, B<-onBlur>
and B<-onSelect> parameters are recognized.  See textfield().

=head2 CREATING A PASSWORD FIELD

   print $query->password_field(-name=>'secret',
                                -value=>'starting value',
                                -size=>50,
                                -maxlength=>80);
        -or-

   print $query->password_field('secret','starting value',50,80);

password_field() is identical to textfield(), except that its contents 
will be starred out on the web page.

JAVASCRIPTING: The B<-onChange>, B<-onFocus>, B<-onBlur>
and B<-onSelect> parameters are recognized.  See textfield().

=head2 CREATING A FILE UPLOAD FIELD

    print $query->filefield(-name=>'uploaded_file',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80);
        -or-

    print $query->filefield('uploaded_file','starting value',50,80);

filefield() will return a file upload field for Netscape 2.0 browsers.
In order to take full advantage of this I<you must use the new 
multipart encoding scheme> for the form.  You can do this either
by calling B<startform()> with an encoding type of B<$CGI::MULTIPART>,
or by calling the new method B<start_multipart_form()> instead of
vanilla B<startform()>.

=over 4

=item B<Parameters>

=item 1.

The first parameter is the required name for the field (-name).  

=item 2.

The optional second parameter is the starting value for the field contents
to be used as the default file name (-default).

The beta2 version of Netscape 2.0 currently doesn't pay any attention
to this field, and so the starting value will always be blank.  Worse,
the field loses its "sticky" behavior and forgets its previous
contents.  The starting value field is called for in the HTML
specification, however, and possibly later versions of Netscape will
honor it.

=item 3.

The optional third parameter is the size of the field in
characters (-size).

=item 4.

The optional fourth parameter is the maximum number of characters the
field will accept (-maxlength).

=back

When the form is processed, you can retrieve the entered filename
by calling param().

       $filename = $query->param('uploaded_file');

In Netscape Beta 1, the filename that gets returned is the full local filename
on the B<remote user's> machine.  If the remote user is on a Unix
machine, the filename will follow Unix conventions:

        /path/to/the/file

On an MS-DOS/Windows machine, the filename will follow DOS conventions:

        C:\PATH\TO\THE\FILE.MSW

On a Macintosh machine, the filename will follow Mac conventions:

        HD 40:Desktop Folder:Sort Through:Reminders

In Netscape Beta 2, only the last part of the file path (the filename
itself) is returned.  I don't know what the release behavior will be.

The filename returned is also a file handle.  You can read the contents
of the file using standard Perl file reading calls:

        # Read a text file and print it out
        while (<$filename>) {
           print;
        }

        # Copy a binary file to somewhere safe
        open (OUTFILE,">>/usr/local/web/users/feedback");
        while ($bytesread=read($filename,$buffer,1024)) {
           print OUTFILE $buffer;
        }

JAVASCRIPTING: The B<-onChange>, B<-onFocus>, B<-onBlur>
and B<-onSelect> parameters are recognized.  See textfield()
for details. 

=head2 CREATING A POPUP MENU

   print $query->popup_menu('menu_name',
                            ['eenie','meenie','minie'],
                            'meenie');

      -or-

   %labels = ('eenie'=>'your first choice',
              'meenie'=>'your second choice',
              'minie'=>'your third choice');
   print $query->popup_menu('menu_name',
                            ['eenie','meenie','minie'],
                            'meenie',\%labels);

        -or (named parameter style)-

   print $query->popup_menu(-name=>'menu_name',
                            -values=>['eenie','meenie','minie'],
                            -default=>'meenie',
                            -labels=>\%labels);

popup_menu() creates a menu.

=over 4

=item 1.

The required first argument is the menu's name (-name).

=item 2.

The required second argument (-values) is an array B<reference>
containing the list of menu items in the menu.  You can pass the
method an anonymous array, as shown in the example, or a reference to
a named array, such as "\@foo".

=item 3.

The optional third parameter (-default) is the name of the default
menu choice.  If not specified, the first item will be the default.
The values of the previous choice will be maintained across queries.

=item 4.

The optional fourth parameter (-labels) is provided for people who
want to use different values for the user-visible label inside the
popup menu nd the value returned to your script.  It's a pointer to an
associative array relating menu values to user-visible labels.  If you
leave this parameter blank, the menu values will be displayed by
default.  (You can also leave a label undefined if you want to).

=back

When the form is processed, the selected value of the popup menu can
be retrieved using:

      $popup_menu_value = $query->param('menu_name');

JAVASCRIPTING: popup_menu() recognizes the following event handlers:
B<-onChange>, B<-onFocus>, and B<-onBlur>.  See the textfield()
section for details on when these handlers are called.

=head2 CREATING A SCROLLING LIST

   print $query->scrolling_list('list_name',
                                ['eenie','meenie','minie','moe'],
                                ['eenie','moe'],5,'true');
      -or-

   print $query->scrolling_list('list_name',
                                ['eenie','meenie','minie','moe'],
                                ['eenie','moe'],5,'true',
                                \%labels);

        -or-

   print $query->scrolling_list(-name=>'list_name',
                                -values=>['eenie','meenie','minie','moe'],
                                -default=>['eenie','moe'],
                                -size=>5,
                                -multiple=>'true',
                                -labels=>\%labels);

scrolling_list() creates a scrolling list.  

=over 4

=item B<Parameters:>

=item 1.

The first and second arguments are the list name (-name) and values
(-values).  As in the popup menu, the second argument should be an
array reference.

=item 2.

The optional third argument (-default) can be either a reference to a
list containing the values to be selected by default, or can be a
single value to select.  If this argument is missing or undefined,
then nothing is selected when the list first appears.  In the named
parameter version, you can use the synonym "-defaults" for this
parameter.

=item 3.

The optional fourth argument is the size of the list (-size).

=item 4.

The optional fifth argument can be set to true to allow multiple
simultaneous selections (-multiple).  Otherwise only one selection
will be allowed at a time.

=item 5.

The optional sixth argument is a pointer to an associative array
containing long user-visible labels for the list items (-labels).
If not provided, the values will be displayed.

When this form is procesed, all selected list items will be returned as
a list under the parameter name 'list_name'.  The values of the
selected items can be retrieved with:

      @selected = $query->param('list_name');

=back

JAVASCRIPTING: scrolling_list() recognizes the following event handlers:
B<-onChange>, B<-onFocus>, and B<-onBlur>.  See textfield() for
the description of when these handlers are called.

=head2 CREATING A GROUP OF RELATED CHECKBOXES

   print $query->checkbox_group(-name=>'group_name',
                                -values=>['eenie','meenie','minie','moe'],
                                -default=>['eenie','moe'],
                                -linebreak=>'true',
                                -labels=>\%labels);

   print $query->checkbox_group('group_name',
                                ['eenie','meenie','minie','moe'],
                                ['eenie','moe'],'true',\%labels);

   HTML3-COMPATIBLE BROWSERS ONLY:

   print $query->checkbox_group(-name=>'group_name',
                                -values=>['eenie','meenie','minie','moe'],
                                -rows=2,-columns=>2);
    

checkbox_group() creates a list of checkboxes that are related
by the same name.

=over 4

=item B<Parameters:>

=item 1.

The first and second arguments are the checkbox name and values,
respectively (-name and -values).  As in the popup menu, the second
argument should be an array reference.  These values are used for the
user-readable labels printed next to the checkboxes as well as for the
values passed to your script in the query string.

=item 2.

The optional third argument (-default) can be either a reference to a
list containing the values to be checked by default, or can be a
single value to checked.  If this argument is missing or undefined,
then nothing is selected when the list first appears.

=item 3.

The optional fourth argument (-linebreak) can be set to true to place
line breaks between the checkboxes so that they appear as a vertical
list.  Otherwise, they will be strung together on a horizontal line.

=item 4.

The optional fifth argument is a pointer to an associative array
relating the checkbox values to the user-visible labels that will will
be printed next to them (-labels).  If not provided, the values will
be used as the default.

=item 5.

B<HTML3-compatible browsers> (such as Netscape) can take advantage 
of the optional 
parameters B<-rows>, and B<-columns>.  These parameters cause
checkbox_group() to return an HTML3 compatible table containing
the checkbox group formatted with the specified number of rows
and columns.  You can provide just the -columns parameter if you
wish; checkbox_group will calculate the correct number of rows
for you.

To include row and column headings in the returned table, you
can use the B<-rowheader> and B<-colheader> parameters.  Both
of these accept a pointer to an array of headings to use.
The headings are just decorative.  They don't reorganize the
interpetation of the checkboxes -- they're still a single named
unit.

=back

When the form is processed, all checked boxes will be returned as
a list under the parameter name 'group_name'.  The values of the
"on" checkboxes can be retrieved with:

      @turned_on = $query->param('group_name');

The value returned by checkbox_group() is actually an array of button
elements.  You can capture them and use them within tables, lists,
or in other creative ways:

    @h = $query->checkbox_group(-name=>'group_name',-values=>\@values);
    &use_in_creative_way(@h);

JAVASCRIPTING: checkbox_group() recognizes the B<-onClick>
parameter.  This specifies a JavaScript code fragment or
function call to be executed every time the user clicks on
any of the buttons in the group.  You can retrieve the identity
of the particular button clicked on using the "this" variable.

=head2 CREATING A STANDALONE CHECKBOX

    print $query->checkbox(-name=>'checkbox_name',
                           -checked=>'checked',
                           -value=>'ON',
                           -label=>'CLICK ME');

        -or-

    print $query->checkbox('checkbox_name','checked','ON','CLICK ME');

checkbox() is used to create an isolated checkbox that isn't logically
related to any others.

=over 4

=item B<Parameters:>

=item 1.

The first parameter is the required name for the checkbox (-name).  It
will also be used for the user-readable label printed next to the
checkbox.

=item 2.

The optional second parameter (-checked) specifies that the checkbox
is turned on by default.  Synonyms are -selected and -on.

=item 3.

The optional third parameter (-value) specifies the value of the
checkbox when it is checked.  If not provided, the word "on" is
assumed.

=item 4.

The optional fourth parameter (-label) is the user-readable label to
be attached to the checkbox.  If not provided, the checkbox name is
used.

=back

The value of the checkbox can be retrieved using:

    $turned_on = $query->param('checkbox_name');

JAVASCRIPTING: checkbox() recognizes the B<-onClick>
parameter.  See checkbox_group() for further details.

=head2 CREATING A RADIO BUTTON GROUP

   print $query->radio_group(-name=>'group_name',
                             -values=>['eenie','meenie','minie'],
                             -default=>'meenie',
                             -linebreak=>'true',
                             -labels=>\%labels);

        -or-

   print $query->radio_group('group_name',['eenie','meenie','minie'],
                                          'meenie','true',\%labels);


   HTML3-COMPATIBLE BROWSERS ONLY:

   print $query->radio_group(-name=>'group_name',
                             -values=>['eenie','meenie','minie','moe'],
                             -rows=2,-columns=>2);

radio_group() creates a set of logically-related radio buttons
(turning one member of the group on turns the others off)

=over 4

=item B<Parameters:>

=item 1.

The first argument is the name of the group and is required (-name).

=item 2.

The second argument (-values) is the list of values for the radio
buttons.  The values and the labels that appear on the page are
identical.  Pass an array I<reference> in the second argument, either
using an anonymous array, as shown, or by referencing a named array as
in "\@foo".

=item 3.

The optional third parameter (-default) is the name of the default
button to turn on. If not specified, the first item will be the
default.  You can provide a nonexistent button name, such as "-" to
start up with no buttons selected.

=item 4.

The optional fourth parameter (-linebreak) can be set to 'true' to put
line breaks between the buttons, creating a vertical list.

=item 5.

The optional fifth parameter (-labels) is a pointer to an associative
array relating the radio button values to user-visible labels to be
used in the display.  If not provided, the values themselves are
displayed.

=item 6.

B<HTML3-compatible browsers> (such as Netscape) can take advantage 
of the optional 
parameters B<-rows>, and B<-columns>.  These parameters cause
radio_group() to return an HTML3 compatible table containing
the radio group formatted with the specified number of rows
and columns.  You can provide just the -columns parameter if you
wish; radio_group will calculate the correct number of rows
for you.

To include row and column headings in the returned table, you
can use the B<-rowheader> and B<-colheader> parameters.  Both
of these accept a pointer to an array of headings to use.
The headings are just decorative.  They don't reorganize the
interpetation of the radio buttons -- they're still a single named
unit.

=back

When the form is processed, the selected radio button can
be retrieved using:

      $which_radio_button = $query->param('group_name');

The value returned by radio_group() is actually an array of button
elements.  You can capture them and use them within tables, lists,
or in other creative ways:

    @h = $query->radio_group(-name=>'group_name',-values=>\@values);
    &use_in_creative_way(@h);

=head2 CREATING A SUBMIT BUTTON 

   print $query->submit(-name=>'button_name',
                        -value=>'value');

        -or-

   print $query->submit('button_name','value');

submit() will create the query submission button.  Every form
should have one of these.

=over 4

=item B<Parameters:>

=item 1.

The first argument (-name) is optional.  You can give the button a
name if you have several submission buttons in your form and you want
to distinguish between them.  The name will also be used as the
user-visible label.  Be aware that a few older browsers don't deal with this correctly and
B<never> send back a value from a button.

=item 2.

The second argument (-value) is also optional.  This gives the button
a value that will be passed to your script in the query string.

=back

You can figure out which button was pressed by using different
values for each one:

     $which_one = $query->param('button_name');

JAVASCRIPTING: radio_group() recognizes the B<-onClick>
parameter.  See checkbox_group() for further details.

=head2 CREATING A RESET BUTTON

   print $query->reset

reset() creates the "reset" button.  Note that it restores the
form to its value from the last time the script was called, 
NOT necessarily to the defaults.

=head2 CREATING A DEFAULT BUTTON

   print $query->defaults('button_label')

defaults() creates a button that, when invoked, will cause the
form to be completely reset to its defaults, wiping out all the
changes the user ever made.

=head2 CREATING A HIDDEN FIELD

        print $query->hidden(-name=>'hidden_name',
                             -default=>['value1','value2'...]);

                -or-

        print $query->hidden('hidden_name','value1','value2'...);

hidden() produces a text field that can't be seen by the user.  It
is useful for passing state variable information from one invocation
of the script to the next.

=over 4

=item B<Parameters:>

=item 1.

The first argument is required and specifies the name of this
field (-name).

=item 2.  

The second argument is also required and specifies its value
(-default).  In the named parameter style of calling, you can provide
a single value here or a reference to a whole list

=back

Fetch the value of a hidden field this way:

     $hidden_value = $query->param('hidden_name');

Note, that just like all the other form elements, the value of a
hidden field is "sticky".  If you want to replace a hidden field with
some other values after the script has been called once you'll have to
do it manually:

     $query->param('hidden_name','new','values','here');

=head2 CREATING A CLICKABLE IMAGE BUTTON

     print $query->image_button(-name=>'button_name',
                                -src=>'/source/URL',
                                -align=>'MIDDLE');      

        -or-

     print $query->image_button('button_name','/source/URL','MIDDLE');

image_button() produces a clickable image.  When it's clicked on the
position of the click is returned to your script as "button_name.x"
and "button_name.y", where "button_name" is the name you've assigned
to it.

JAVASCRIPTING: image_button() recognizes the B<-onClick>
parameter.  See checkbox_group() for further details.

=over 4

=item B<Parameters:>

=item 1.

The first argument (-name) is required and specifies the name of this
field.

=item 2.

The second argument (-src) is also required and specifies the URL

=item 3.
The third option (-align, optional) is an alignment type, and may be
TOP, BOTTOM or MIDDLE

=back

Fetch the value of the button this way:
     $x = $query->param('button_name.x');
     $y = $query->param('button_name.y');

=head2 CREATING A JAVASCRIPT ACTION BUTTON

     print $query->button(-name=>'button_name',
                          -value=>'user visible label',
                          -onClick=>"do_something()");

        -or-

     print $query->button('button_name',"do_something()");

button() produces a button that is compatible with Netscape 2.0's
JavaScript.  When it's pressed the fragment of JavaScript code
pointed to by the B<-onClick> parameter will be executed.  On
non-Netscape browsers this form element will probably not even
display.

=head1 NETSCAPE COOKIES

Netscape browsers versions 1.1 and higher support a so-called
"cookie" designed to help maintain state within a browser session.
CGI.pm has several methods that support cookies.

A cookie is a name=value pair much like the named parameters in a CGI
query string.  CGI scripts create one or more cookies and send
them to the browser in the HTTP header.  The browser maintains a list
of cookies that belong to a particular Web server, and returns them
to the CGI script during subsequent interactions.

In addition to the required name=value pair, each cookie has several
optional attributes:

=over 4

=item 1. an expiration time

This is a time/date string (in a special GMT format) that indicates
when a cookie expires.  The cookie will be saved and returned to your
script until this expiration date is reached if the user exits
Netscape and restarts it.  If an expiration date isn't specified, the cookie
will remain active until the user quits Netscape.

=item 2. a domain

This is a partial or complete domain name for which the cookie is 
valid.  The browser will return the cookie to any host that matches
the partial domain name.  For example, if you specify a domain name
of ".capricorn.com", then Netscape will return the cookie to
Web servers running on any of the machines "www.capricorn.com", 
"www2.capricorn.com", "feckless.capricorn.com", etc.  Domain names
must contain at least two periods to prevent attempts to match
on top level domains like ".edu".  If no domain is specified, then
the browser will only return the cookie to servers on the host the
cookie originated from.

=item 3. a path

If you provide a cookie path attribute, the browser will check it
against your script's URL before returning the cookie.  For example,
if you specify the path "/cgi-bin", then the cookie will be returned
to each of the scripts "/cgi-bin/tally.pl", "/cgi-bin/order.pl",
and "/cgi-bin/customer_service/complain.pl", but not to the script
"/cgi-private/site_admin.pl".  By default, path is set to "/", which
causes the cookie to be sent to any CGI script on your site.

=item 4. a "secure" flag

If the "secure" attribute is set, the cookie will only be sent to your
script if the CGI request is occurring on a secure channel, such as SSL.

=back

The interface to Netscape cookies is the B<cookie()> method:

    $cookie = $query->cookie(-name=>'sessionID',
                             -value=>'xyzzy',
                             -expires=>'+1h',
                             -path=>'/cgi-bin/database',
                             -domain=>'.capricorn.org',
                             -secure=>1);
    print $query->header(-cookie=>$cookie);

B<cookie()> creates a new cookie.  Its parameters include:

=over 4

=item B<-name>

The name of the cookie (required).  This can be any string at all.
Although Netscape limits its cookie names to non-whitespace
alphanumeric characters, CGI.pm removes this restriction by escaping
and unescaping cookies behind the scenes.

=item B<-value>

The value of the cookie.  This can be any scalar value,
array reference, or even associative array reference.  For example,
you can store an entire associative array into a cookie this way:

        $cookie=$query->cookie(-name=>'family information',
                               -value=>\%childrens_ages);

=item B<-path>

The optional partial path for which this cookie will be valid, as described
above.

=item B<-domain>

The optional partial domain for which this cookie will be valid, as described
above.

=item B<-expires>

The optional expiration date for this cookie.  The format is as described 
in the section on the B<header()> method:

        "+1h"  one hour from now

=item B<-secure>

If set to true, this cookie will only be used within a secure
SSL session.

=back

The cookie created by cookie() must be incorporated into the HTTP
header within the string returned by the header() method:

        print $query->header(-cookie=>$my_cookie);

To create multiple cookies, give header() an array reference:

        $cookie1 = $query->cookie(-name=>'riddle_name',
                                  -value=>"The Sphynx's Question");
        $cookie2 = $query->cookie(-name=>'answers',
                                  -value=>\%answers);
        print $query->header(-cookie=>[$cookie1,$cookie2]);

To retrieve a cookie, request it by name by calling cookie()
method without the B<-value> parameter:

        use CGI;
        $query = new CGI;
        %answers = $query->cookie(-name=>'answers');
        # $query->cookie('answers') will work too!

See the B<cookie.cgi> example script for some ideas on how to use
cookies effectively.

B<NOTE:> There appear to be some (undocumented) restrictions on
Netscape cookies.  In Netscape 2.01, at least, I haven't been able to
set more than three cookies at a time.  There may also be limits on
the length of cookies.  If you need to store a lot of information,
it's probably better to create a unique session ID, store it in a
cookie, and use the session ID to locate an external file/database
saved on the server's side of the connection.

=head1 WORKING WITH NETSCAPE FRAMES

It's possible for CGI.pm scripts to write into several browser
panels and windows using Netscape's frame mechanism.  
There are three techniques for defining new frames programatically:

=over 4

=item 1. Create a <Frameset> document

After writing out the HTTP header, instead of creating a standard
HTML document using the start_html() call, create a <FRAMESET> 
document that defines the frames on the page.  Specify your script(s)
(with appropriate parameters) as the SRC for each of the frames.

There is no specific support for creating <FRAMESET> sections 
in CGI.pm, but the HTML is very simple to write.  See the frame
documentation in Netscape's home pages for details 

  http://home.netscape.com/assist/net_sites/frames.html

=item 2. Specify the destination for the document in the HTTP header

You may provide a B<-target> parameter to the header() method:
   
    print $q->header(-target=>'ResultsWindow');

This will tell Netscape to load the output of your script into the
frame named "ResultsWindow".  If a frame of that name doesn't
already exist, Netscape will pop up a new window and load your
script's document into that.  There are a number of magic names
that you can use for targets.  See the frame documents on Netscape's
home pages for details.

=item 3. Specify the destination for the document in the <FORM> tag

You can specify the frame to load in the FORM tag itself.  With
CGI.pm it looks like this:

    print $q->startform(-target=>'ResultsWindow');

When your script is reinvoked by the form, its output will be loaded
into the frame named "ResultsWindow".  If one doesn't already exist
a new window will be created.

=back

The script "frameset.cgi" in the examples directory shows one way to
create pages in which the fill-out form and the response live in
side-by-side frames.

=head1 DEBUGGING

If you are running the script
from the command line or in the perl debugger, you can pass the script
a list of keywords or parameter=value pairs on the command line or 
from standard input (you don't have to worry about tricking your
script into reading from environment variables).
You can pass keywords like this:

    your_script.pl keyword1 keyword2 keyword3

or this:

   your_script.pl keyword1+keyword2+keyword3

or this:

    your_script.pl name1=value1 name2=value2

or this:

    your_script.pl name1=value1&name2=value2

or even as newline-delimited parameters on standard input.

When debugging, you can use quotes and backslashes to escape 
characters in the familiar shell manner, letting you place
spaces and other funny characters in your parameter=value
pairs:

   your_script.pl "name1='I am a long value'" "name2=two\ words"

=head2 DUMPING OUT ALL THE NAME/VALUE PAIRS

The dump() method produces a string consisting of all the query's
name/value pairs formatted nicely as a nested list.  This is useful
for debugging purposes:

    print $query->dump
    

Produces something that looks like:

    <UL>
    <LI>name1
        <UL>
        <LI>value1
        <LI>value2
        </UL>
    <LI>name2
        <UL>
        <LI>value1
        </UL>
    </UL>

You can pass a value of 'true' to dump() in order to get it to
print the results out as plain text, suitable for incorporating
into a <PRE> section.

As a shortcut, as of version 1.56 you can interpolate the entire 
CGI object into a string and it will be replaced with the
the a nice HTML dump shown above:

    $query=new CGI;
    print "<H2>Current Values</H2> $query\n";

=head1 FETCHING ENVIRONMENT VARIABLES

Some of the more useful environment variables can be fetched
through this interface.  The methods are as follows:

=item B<accept()>

Return a list of MIME types that the remote browser
accepts. If you give this method a single argument
corresponding to a MIME type, as in
$query->accept('text/html'), it will return a
floating point value corresponding to the browser's
preference for this type from 0.0 (don't want) to 1.0.
Glob types (e.g. text/*) in the browser's accept list
are handled correctly.

=item B<raw_cookie()>

Returns the HTTP_COOKIE variable, an HTTP extension
implemented by Netscape browsers version 1.1
and higher.  Cookies have a special format, and this 
method call just returns the raw form (?cookie dough).
See cookie() for ways of setting and retrieving
cooked cookies.

=item B<user_agent()>

Returns the HTTP_USER_AGENT variable.  If you give
this method a single argument, it will attempt to
pattern match on it, allowing you to do something
like $query->user_agent(netscape);

=item B<path_info()>

Returns additional path information from the script URL.
E.G. fetching /cgi-bin/your_script/additional/stuff will
result in $query->path_info() returning
"additional/stuff".

=item B<path_translated()>

As per path_info() but returns the additional
path information translated into a physical path, e.g.
"/usr/local/etc/httpd/htdocs/additional/stuff".

=item B<remote_host()>

Returns either the remote host name or IP address.
if the former is unavailable.

=item B<script_name()>
Return the script name as a partial URL, for self-refering
scripts.

=item B<referer()>

Return the URL of the page the browser was viewing
prior to fetching your script.  Not available for all
browsers.

=item B<auth_type ()>

Return the authorization/verification method in use for this
script, if any.

=item B<remote_user ()>

Return the authorization/verification name used for user
verification, if this script is protected.

=item B<user_name ()>

Attempt to obtain the remote user's name, using a variety
of different techniques.  This only works with older browsers
such as Mosaic.  Netscape does not reliably report the user
name!

=item B<request_method()>

Returns the method used to access your script, usually
one of 'POST', 'GET' or 'HEAD'.

=head1 AUTHOR INFORMATION

Copyright 1995,1996, Lincoln D. Stein.  All rights reserved.
It may be used and modified freely, but I do request that this copyright
notice remain attached to the file.  You may modify this module as you 
wish, but if you redistribute a modified version, please attach a note
listing the modifications you have made.

Address bug reports and comments to:
lstein@genome.wi.mit.edu

=head1 CREDITS

Thanks very much to:

=over 4

=item Matt Heffron (heffron@falstaff.css.beckman.com)

=item James Taylor (james.taylor@srs.gov)

=item Scott Anguish <sanguish@digifix.com>

=item Mike Jewell (mlj3u@virginia.edu)

=item Timothy Shimmin (tes@kbs.citri.edu.au)

=item Joergen Haegg (jh@axis.se)

=item Laurent Delfosse (delfosse@csgrad1.cs.wvu.edu)

=item Richard Resnick (applepi1@aol.com)

=item Craig Bishop (csb@barwonwater.vic.gov.au)

=item Tony Curtis (tc@vcpc.univie.ac.at)

=item Tim Bunce (Tim.Bunce@ig.co.uk)

=item Tom Christiansen (tchrist@convex.com)

=item Andreas Koenig (k@franz.ww.TU-Berlin.DE)

=item Tim MacKenzie (Tim.MacKenzie@fulcrum.com.au)

=item Kevin B. Hendricks (kbhend@dogwood.tyler.wm.edu)

=item Stephen Dahmen (joyfire@inxpress.net)

=item ...and many many more...


for suggestions and bug fixes.

=back

=head1 A COMPLETE EXAMPLE OF A SIMPLE FORM-BASED SCRIPT


        #!/usr/local/bin/perl
     
        use CGI;
 
        $query = new CGI;

        print $query->header;
        print $query->start_html("Example CGI.pm Form");
        print "<H1> Example CGI.pm Form</H1>\n";
        &print_prompt($query);
        &do_work($query);
        &print_tail;
        print $query->end_html;
 
        sub print_prompt {
           my($query) = @_;
 
           print $query->startform;
           print "<EM>What's your name?</EM><BR>";
           print $query->textfield('name');
           print $query->checkbox('Not my real name');
 
           print "<P><EM>Where can you find English Sparrows?</EM><BR>";
           print $query->checkbox_group(
                                 -name=>'Sparrow locations',
                                 -values=>[England,France,Spain,Asia,Hoboken],
                                 -linebreak=>'yes',
                                 -defaults=>[England,Asia]);
 
           print "<P><EM>How far can they fly?</EM><BR>",
                $query->radio_group(
                        -name=>'how far',
                        -values=>['10 ft','1 mile','10 miles','real far'],
                        -default=>'1 mile');
 
           print "<P><EM>What's your favorite color?</EM>  ";
           print $query->popup_menu(-name=>'Color',
                                    -values=>['black','brown','red','yellow'],
                                    -default=>'red');
 
           print $query->hidden('Reference','Monty Python and the Holy Grail');
 
           print "<P><EM>What have you got there?</EM><BR>";
           print $query->scrolling_list(
                         -name=>'possessions',
                         -values=>['A Coconut','A Grail','An Icon',
                                   'A Sword','A Ticket'],
                         -size=>5,
                         -multiple=>'true');
 
           print "<P><EM>Any parting comments?</EM><BR>";
           print $query->textarea(-name=>'Comments',
                                  -rows=>10,
                                  -columns=>50);
 
           print "<P>",$query->reset;
           print $query->submit('Action','Shout');
           print $query->submit('Action','Scream');
           print $query->endform;
           print "<HR>\n";
        }
 
        sub do_work {
           my($query) = @_;
           my(@values,$key);

           print "<H2>Here are the current settings in this form</H2>";

           foreach $key ($query->param) {
              print "<STRONG>$key</STRONG> -> ";
              @values = $query->param($key);
              print join(", ",@values),"<BR>\n";
          }
        }
 
        sub print_tail {
           print <<END;
        <HR>
        <ADDRESS>Lincoln D. Stein</ADDRESS><BR>
        <A HREF="/">Home Page</A>
        END
        }

=head1 BUGS

This module has grown large and monolithic.  Furthermore it's doing many
things, such as handling URLs, parsing CGI input, writing HTML, etc., that
should be done in separate modules.  It should be discarded in favor of
the CGI::* modules, but somehow I continue to work on it.

Note that the code is truly contorted in order to avoid spurious
warnings when programs are run with the B<-w> switch.

=head1 SEE ALSO

L<CGI::Carp>, L<URI::URL>, L<CGI::Request>, L<CGI::MiniSvr>,
L<CGI::Base>, L<CGI::Form>

=cut

1;
