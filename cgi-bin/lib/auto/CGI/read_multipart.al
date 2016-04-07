# NOTE: Derived from lib/CGI.pm.  Changes made here will be lost.
package CGI;

sub read_multipart {
    my($self,$boundary,$length) = @_;
    my($buffer) = new MultipartBuffer($boundary,$length);
    return unless $buffer;
    my(%header,$body);
    while (!$buffer->eof) {
        %header = $buffer->readHeader;
        # In beta1 it was "Content-disposition".  In beta2 it's "Content-Disposition"
        # Sheesh.
        my($key) = $header{'Content-disposition'} ? 'Content-disposition' : 'Content-Disposition';
        my($param)= $header{$key}=~/ name="([^\"]*)"/;

        # possible bug: our regular expression expects the filename= part to fall
        # at the end of the line.  Netscape doesn't escape quotation marks in file names!!!
        my($filename) = $header{$key}=~/ filename="(.*)"$/;

        # add this parameter to our list
        $self->add_parameter($param);

        # If no filename specified, then just read the data and assign it
        # to our parameter list.
        unless ($filename) {
            my($value) = $buffer->readBody;
            push(@{$self->{$param}},$value);
            next;
        }

        # If we get here, then we are dealing with a potentially large
        # uploaded form.  Save the data to a temporary file, then open
        # the file for reading.
        my($tmpfile) = new TempFile;
        open (OUT,">$$tmpfile") || die "CGI open of $$tmpfile: $!\n";
        chmod 0666,$$tmpfile;    # make sure anyone can delete it.
        my $data;
        while ($data = $buffer->read) {
            print OUT $data;
        }
        close OUT;

        # Now create a new filehandle in the caller's namespace.
        # The name of this filehandle just happens to be identical
        # to the original filename (NOT the name of the temporary
        # file, which is hidden!)
        my($filehandle);
        if ($filename=~/^[a-zA-Z_]/) {
            my($frame,$cp)=(1);
            do { $cp = caller($frame++); } until $cp!~/^CGI/;
            $filehandle = "$cp\:\:$filename";
        } else {
            $filehandle = "\:\:$filename";
        }

        open($filehandle,$$tmpfile) || die "CGI open of $$tmpfile: $!\n";
        binmode($filehandle) if $CGI::needs_binmode;

        push(@{$self->{$param}},$filename);

        # Under Unix, it would be safe to let the temporary file
        # be deleted immediately.  However, I fear that other operating
        # systems are not so forgiving.  Therefore we save a reference
        # to the temporary file in the CGI object so that the file
        # isn't unlinked until the CGI object itself goes out of
        # scope.  This is a bit hacky, but it has the interesting side
        # effect that one can access the name of the tmpfile by
        # asking for $query->{$query->param('foo')}, where 'foo'
        # is the name of the file upload field.
        $self->{'.tmpfiles'}->{$filename}=$tmpfile;

    }

}

1;
