# Printing::Jdf #

This is a module for parsing Adobe Job Definition Format files that use Kodak's
SSi extensions.

## Example ##

    my $xml = slurp('/path/to/file.jdf');
    my $jdf = Printing::Jdf.new($xml);

## Documentation ##

### Printing::Jdf ###

#### Auditpool ####

    Returns a Printing::Jdf::AuditPool object for the provided JDF file

#### ResourcePool ####

    Returns a Printing::Jdf::ResourcePool object for the provided JDF file

#### ::mm ####

    Converts Pts to Millimetres, rounded to the closest millimetre

### Printing::Jdf::AuditPool ###

#### Created ####

    Returns a Hash with the following keys:

    * `AgentName` - the name of the generator used to create the JDF file
    * `AgentVersion` - the version of the generator
    * `TimeStamp` - a DateTime object representing the date the file was created

### Printing::Jdf::ResourcePool ###

#### ColorantOrder ####

    Returns a List of Strings of the names of the colours in the document

#### Layout ####

    Returns a Hash with the following keys:

    * `Bleed` - the amount of bleed used in the document, in millimetres
    * `PageAdjustments` - a Hash representing the page offsets
        `Odd` - odd page offsets
            `X` - horizontal offset
            `Y` - vertical offset
        `Even` - even page offsets
            `X` - horizontal offset
            `Y` - vertical offset
    * `Signatures` - an array of the Signatures in the document
        Each Signature is a Hash containing the following keys:
            `Name` - the name of the signature
            `PressRun` - the number of the press run
            `Template` - an IO::Path object of the template file

#### Runlist ####

    Returns an Array of Hashes representing each page in the runlist

    * `Run` - the run number of the page
    * `Page` - the page number
    * `Url` - a IO::Path object for the file
    * `Centered` - a Bool that is True if the page is centered
    * `Offsets` - a Hash of the page offsets in millimetres
        see Layout<PageAdjustments>
    * `Scaling` - a Hash with the keys `X` and `Y` representing the scaling percentage of the page

## License ##

This module is licensed under the terms of the Mozilla Public License 2.0.

Adobe, Kodak, Preps and Creo are trademarks of their respective owners.
