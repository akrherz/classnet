# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub image_button {
    my($self,@p) = @_;

    my($name,$src,$alignment,@other) =
        $self->rearrange([NAME,SRC,ALIGN],@p);

    my($align) = $alignment ? "ALIGN=\U$alignment" : '';
    $name=$self->escapeHTML($name);
    return qq/<INPUT TYPE="image" NAME="$name" SRC="$src" $align @other>/;
}

#### Method: self_url
# Returns a URL containing the current script and all its
# param/value pairs arranged as a query.  You can use this
# to create a link that, when selected, will reinvoke the
# script with all its state information preserved.
####
1;
