# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub dump {
    my($self) = @_;
    my($param,$value,@result);
    return '<UL></UL>' unless $self->param;
    push(@result,"<UL>");
    foreach $param ($self->param) {
        my($name)=$self->escapeHTML($param);
        push(@result,"<LI><STRONG>$param</STRONG>");
        push(@result,"<UL>");
        foreach $value ($self->param($param)) {
            $value = $self->escapeHTML($value);
            push(@result,"<LI>$value");
        }
        push(@result,"</UL>");
    }
    push(@result,"</UL>\n");
    return join("\n",@result);
}

#### Method: save
# Write values out to a filehandle in such a way that they can
# be reinitialized by the filehandle form of the new() method
####
1;
