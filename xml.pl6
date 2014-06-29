use v6;
use XML;

my Str $x = slurp("test.jdf");
my XML::Document $doc = from-xml($x);

my $jobId = $doc.root<JobID>;

my XML::Element $ap = $doc.getElementsByTagName("AuditPool")[0];
my XML::Element $c = $ap.getElementsByTagName("Created")[0];

my $agentName = $c<AgentName>;
my $agentVersion = $c<AgentVersion>;
my $timeStamp = $c<TimeStamp>;

my $rp = $doc.getElementsByTagName("ResourcePool")[0];
my $cc = $rp.getElementsByTagName("ColorantControl")[0];
my $co = $rp.getElementsByTagName("ColorantOrder")[0];
my @colours = $co.getElementsByTagName("SeparationSpec");
map { say $_<Name> }, @colours;

my $layout = $rp.getElementsByTagName("Layout")[0];
my $bleed = $layout<SSi:JobDefaultBleedMargin>;
my $adjustments = $layout<SSi:JobPageAdjustments>;

multi sub to-mm(Str $points) {
	to-mm($points.Rat);
}

multi sub to-mm(Rat $points) {
	# 1 inch = 25.4 mm
	my Rat constant $inch = 25.4;
	# 1 point = 1/72 of an inch
	# XXX can't make this a constant as it breaks the debugger
	my Rat $mm = $inch / 72;
	return ($mm * $points).round;
}

say to-mm($bleed);

my @offsets = $adjustments.split(' ');

for @offsets {
        say to-mm(.Rat);
}


# vim: ft=perl6
