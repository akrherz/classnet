# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub hidden {
    my($self,@p) = @_;

    # this is the one place where we departed from our standard
    # calling scheme, so we have to special-case (darn)
    my(@result,@value);
    my($name,$default,$override,@other) = 
        $self->rearrange([NAME,[DEFAULT,VALUE,VALUES],[OVERRIDE,FORCE]],@p);

    my($do_override);
    if ( $p[0]=~/^-/ || $self->use_named_parameters ) {
        @value = ref($default) ? @{$default} : $default;
        $do_override = $override;
    } else {
        foreach ($default,$override,@other) {
            push(@value,$_) if defined($_) && ($_ ne '');
        }
    }

    # use previous values if override is not set
    @value = $self->param($name)
        if !$do_override && $self->param($name) ne '';

    $name=$self->escapeHTML($name);
    foreach (@value) {
        $_=$self->escapeHTML($_);
        push(@result,qq/<INPUT TYPE="hidden" NAME="$name" VALUE="$_">/);
    }
    return join("\n",@result);
}

#### Method: image_button
# Parameters:
#   $name -> Name of the button
#   $src ->  URL of the image source
#   $align -> Alignment style (TOP, BOTTOM or MIDDLE)
# Returns:
#   A string containing a <INPUT TYPE="image" NAME="name" SRC="url" ALIGN="alignment">
####
1;
