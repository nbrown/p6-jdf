use v6;
use XML;

role Jdf::Pool {
    has XML::Element $.Pool;

    method new(XML::Element $Pool) {
        return self.bless(:$Pool);
    }
}

class Jdf::AuditPool is Jdf::Pool {
    method Created returns Hash {
        my XML::Element $c = Jdf::get($.Pool, "Created");
        return {
            AgentName => $c<AgentName>,
            AgentVersion => $c<AgentVersion>,
            TimeStamp => DateTime.new($c<TimeStamp>)
        };
    }
}

class Jdf::ResourcePool is Jdf::Pool {
    method ColorantOrder returns List {
        my XML::Element $co = Jdf::get($.Pool, <ColorantOrder>, Recurse => 1);
        my XML::Element @ss = Jdf::get($co, <SeparationSpec>, Single => False);
        return @ss.map(*<Name>);
    }

    method Layout returns Hash {
        my XML::Element $layout = Jdf::get($.Pool, <Layout>);
        my Str @pa = $layout<SSi:JobPageAdjustments>.split(' ');
        my XML::Element @sigs = Jdf::get($layout, <Signature>, Single => False);
        return {
            Bleed => Jdf::mm($layout<SSi:JobDefaultBleedMargin>),
            PageAdjustments => {
                Odd => { X => Jdf::mm(@pa[0]), Y => Jdf::mm(@pa[1]) },
                Even => { X => Jdf::mm(@pa[2]), Y => Jdf::mm(@pa[3]) }
            },
            Signatures => parseSignatures(@sigs)
        };
    }

    method Runlist returns Array {
        my XML::Element $runlist = Jdf::get($.Pool, <RunList>);
        my XML::Element @runlists = Jdf::get($runlist, <RunList>, Single => False);
        my @files;
        for @runlists -> $root {
            my XML::Element $layout = Jdf::get($root, <LayoutElement>);
            my XML::Element $pagecell = Jdf::get($root, <SSi:PageCell>);
            my XML::Element $filespec = Jdf::get($layout, <FileSpec>);
            @files.push: {
                Run => $root<Run>,
                Page => $root<Run> + 1,
                Url => IO::Path.new($filespec<URL>),
                CenterOffset => parseOffset($pagecell<SSi:RunListCenterOffset>),
                Centered =>
                    $pagecell<SSi:RunListCentered> == 0 ?? False !! True,
                Offsets => parseOffset($pagecell<SSi:RunListOffsets>),
                Scaling => parseScaling($pagecell<SSi:RunListScaling>)
            };
        }
        return @files;
    }

    sub parseSignatures(@signatures) returns Array {
        my Hash @s;
        for @signatures {
            my $eit = Jdf::get($_, <SSi:ExternalImpositionTemplate>);
            my $fs = Jdf::get($eit, <FileSpec>);
            my %sig =
                Name => $_<Name>,
                PressRun => $_<SSi:PressRunNo>.Int,
                Template => IO::Path.new($fs<URL>)
            ;
            @s.push: {%sig};
        }
        return @s;
    }

    our sub parseOffset($offset) returns Hash {
        my Str @sets = $offset.split(' ');
        @sets = ('0', '0') if $offset eq "0";
        return { X => Jdf::mm(@sets[0]), Y => Jdf::mm(@sets[1]) };
    }

    our sub parseScaling($scaling) returns Hash {
        my Str @sc = $scaling.split(' ');
        return { X => @sc[0]*100, Y => @sc[1]*100 };
    }
}

class Jdf {
    has XML::Document $.jdf;
    has Jdf::AuditPool $.AuditPool;
    has Jdf::ResourcePool $.ResourcePool;

    method new(Str $jdf-xml) returns Jdf {
        my XML::Document $jdf = from-xml($jdf-xml);
        my Jdf::AuditPool $AuditPool .= new(getPool($jdf, "AuditPool"));
        my Jdf::ResourcePool $ResourcePool .= new(getPool($jdf, "ResourcePool"));
        return self.bless(:$jdf, :$AuditPool, :$ResourcePool);
    }

    our sub get(XML::Element $xml, Str $TAG, Bool :$Single = True,Int :$Recurse = 0) {
        return $xml.elements(:$TAG, SINGLE => $Single, RECURSE => $Recurse);
    }

    sub getPool(XML::Document $xml, Str $name) returns XML::Element {
        return $xml.elements(TAG => $name, :SINGLE);
    }

    our proto mm($pts) returns Int { * }

    our multi sub mm(Str $pts) returns Int {
        mm($pts.Rat);
    }

    our multi sub mm(Int $pts) returns Int {
        mm($pts.Rat);
    }

    our multi sub mm(Rat $pts) returns Int {
        my Rat constant $inch = 25.4;
        my Rat constant $mm = $inch / 72;
        return ($mm * $pts).round;
    }
}

# vim: ft=perl6 ts=4
