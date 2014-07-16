# Printing::Jdf #

This is a module for parsing Adobe Job Definition Format files that use Kodak's
SSi extensions.

## Example ##

    my $xml = slurp('/path/to/file.jdf');
    my $jdf = Printing::Jdf.new($xml);

## Methods ##

 - `Auditpool`

    Returns a Printing::Jdf::AuditPool object

 - `ResourcePool`

    Returns a Printing::Jdf::ResourcePool object

## License ##

This module is licensed under the terms of the Mozilla Public License 2.0.

Adobe, Kodak, Preps and Creo are trademarks of their respective owners.
