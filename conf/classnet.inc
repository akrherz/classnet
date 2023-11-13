DocumentRoot /local/classnet/html
ScriptAlias /cgi-bin/ "/local/classnet/cgi-bin/"

<Directory "/local/classnet/cgi-bin">
AllowOverride All
Options None
Require all granted
</Directory>
<Directory "/local/classnet/html">
AllowOverride All
Options None
Require all granted
</Directory>
