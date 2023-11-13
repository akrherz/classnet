DocumentRoot /local/classnet/html
ScriptAlias /cgi-bin/ "/local/classnet/cgi-bin/"

<Directory "/local/classnet/cgi-bin">
  SetHandler cgi-script
  AllowOverride All
  Options +FollowSymLinks +ExecCGI
  Require all granted
</Directory>

<Directory "/local/classnet/html">
  AllowOverride All
  Require all granted
</Directory>
