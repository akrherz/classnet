# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub clear_cache {
   # get file names
   opendir(CF,$CACHE);
   my @files = grep(/^\w{4}\.\d{2}\w{3}\d{4}/,readdir(CF));
   close CF;
   # delete files older than 30 days
   foreach $fname (@files) {
      if ((-W "$CACHE/$fname") > 30) {
          unlink "$CACHE/$fname";
      }
   }
}

1;
