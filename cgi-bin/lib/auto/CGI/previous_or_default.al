# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub previous_or_default {
    my($self,$name,$defaults,$override) = @_;
    my(%selected);

    if (!$override && ($self->inited || $self->param($name))) {
        grep($selected{$_}++,$self->param($name));
    } elsif (defined($defaults) && ref($defaults) && 
             (ref($defaults) eq 'ARRAY')) {
        grep($selected{$_}++,@{$defaults});
    } else {
        $selected{$defaults}++ if defined($defaults);
    }

    return %selected;
}

############ SUPPORT ROUTINES FOR THE NEW MULTIPART ENCODING ##########
package MultipartBuffer;

1;
