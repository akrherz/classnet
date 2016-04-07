# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub checkbox_group {

    my($self,@p) = @_;
    my($name,$values,$defaults,$linebreak,$labels,$rows,$columns,
       $rowheaders,$colheaders,$override,$nolabels,@other) =
        $self->rearrange([NAME,[VALUES,VALUE],[DEFAULTS,DEFAULT],
                          LINEBREAK,LABELS,ROWS,[COLUMNS,COLS],
                          ROWHEADERS,COLHEADERS,
                          [OVERRIDE,FORCE],NOLABELS],@p);

    my($checked,$break,$result,$label);

    my(%checked) = $self->previous_or_default($name,$defaults,$override);

    $break = $linebreak ? "<BR>" : '';
    $name=$self->escapeHTML($name);

    # Create the elements
    my(@elements);
    my(@values) = @$values ? @$values : $self->param($name);
    foreach (@values) {
        $checked = $checked{$_} ? 'CHECKED' : '';
        $label = '';
        unless (defined($nolabels) && $nolabels) {
            $label = $_;
            $label = $labels->{$_} if defined($labels) && $labels->{$_};
            $label = $self->escapeHTML($label);
        }
        $_ = $self->escapeHTML($_);
        push(@elements,qq/<INPUT TYPE="checkbox" NAME="$name" VALUE="$_" $checked @other>${label} ${break}/);
    }
    return @elements unless $columns;
    return _tableize($rows,$columns,$rowheaders,$colheaders,@elements);
}

# Escape HTML -- used internally
1;
