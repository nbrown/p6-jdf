use v6;
use XML;

role Jdf::Pool {
    has XML::Element $.Pool;

    method new(XML::Element $Pool) {
        return self.bless(:$Pool);
    }

    method getNodes(XML::Element $xml, Str $name) {
        return $xml.getElementsByTagName($name);
    }
}

class Jdf::AuditPool is Jdf::Pool {
    method Created {
        my $c = self.getNodes($.Pool, "Created")[0];
        return {
            AgentName => $c<AgentName>,
            AgentVersion => $c<AgentVersion>,
            TimeStamp => DateTime.new($c<TimeStamp>)
        };
    }
}

class Jdf::ResourcePool is Jdf::Pool {
    method ColorantOrder {
        my $co = self.getNodes($.Pool, "ColorantOrder")[0];
        my @ss = self.getNodes($co, "SeparationSpec");
        return @ss.map(*<Name>);
    }

    method Layout {
        my $layout = self.getNodes($.Pool, "Layout")[0];
        my @pa = $layout<SSi:JobPageAdjustments>.split(' ');
        my @sigs = self.getNodes($layout, "Signature");
        return {
            Bleed => Jdf::mm($layout<SSi:JobDefaultBleedMargin>),
            PageAdjustments => {
                Odd => { X => Jdf::mm(@pa[0]), Y => Jdf::mm(@pa[1]) },
                Even => { X => Jdf::mm(@pa[2]), Y => Jdf::mm(@pa[3]) }
            },
            Signatures => parseSignatures(@sigs),
        };
    }

    method Runlist {
        my $runlist = self.getNodes($.Pool, "RunList")[0];
        my @runlists = self.getNodes($runlist, "RunList");
        my @files;
        for @runlists -> $root {
            my $layout = self.getNodes($root, "LayoutElement")[0];
            my $filespec = self.getNodes($layout, "FileSpec")[0];
            my $pagecell = self.getNodes($root, "SSi:PageCell")[0];
            @files.push: {
                Run => $root<Run>,
                Page => $root<Run> + 1,
                Url => IO::Path.new($filespec<URL>),
                CenterOffset => $pagecell<SSi:RunListCenterOffset>,
                Centered =>
                    $pagecell<SSi:RunListCentered> == 0 ?? False !! True,
                Offsets => parseOffset($pagecell<SSi:RunListOffsets>),
                Scaling => $pagecell<SSi:RunListScaling>
            };
        }
        return @files;
    }

    sub parseSignatures(@signatures) {
        my @s;
        for @signatures {
            my %sig =
                Name => $_<Name>,
                PressRun => $_<SSi:PressRunNo>.Int
            ;
            @s.push: {%sig};
        }
        return @s;
    }

    sub parseOffset($offset) {
        my @sets = $offset.split(' ');
        return { X => @sets[0], Y => @sets[1] };
    }
}

class Jdf {
    has XML::Document $.jdf;
    has Jdf::AuditPool $.AuditPool;
    has Jdf::ResourcePool $.ResourcePool;

    method new(Str $jdf-xml) returns Jdf {
        my XML::Document $jdf = from-xml($jdf-xml);
        my Jdf::AuditPool $AuditPool .= new(self.getPool($jdf, "AuditPool"));
        my Jdf::ResourcePool $ResourcePool .= new(self.getPool($jdf, "ResourcePool"));
        return self.bless(:$jdf, :$AuditPool, :$ResourcePool);
    }

    method getPool(XML::Document $xml, Str $name) {
        return $xml.getElementsByTagName($name)[0];
    }

    our proto mm($pts) { * }

    our multi sub mm(Str $pts) {
        mm($pts.Rat);
    }

    our multi sub mm(Int $pts) {
        mm($pts.Rat);
    }

    our multi sub mm(Rat $pts) {
        my Rat constant $inch = 25.4;
        my Rat constant $mm = $inch / 72;
        return ($mm * $pts).round;
    }
}

# vim: ft=perl6 ts=4
