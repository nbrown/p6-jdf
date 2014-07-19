use v6;
use Printing::Jdf;

=begin LICENSE

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

=end LICENSE

if not @*ARGS {
    say "Usage:";
    say "$*PROGRAM_NAME example.jdf [--pages]";
    exit(0);
}

my $jdf = Printing::Jdf.new(slurp(@*ARGS[0]));
my $option = @*ARGS[1];

say "Templates:";
for @($jdf.ResourcePool.Layout<Signatures>) -> $signature {
    my $parts = $signature<Template>.split('/');
    my $use = $parts.splice(6);
    printf("%02d: ", $signature<PressRun>);
    say unurl($use.join(' - '));
}

blank();

say "Offsets:";

my $adj = $jdf.ResourcePool.Layout<PageAdjustments>;
say "\tX\tY";
say "Odd:\t" ~ $adj<Odd><X> ~ "\t" ~ $adj<Odd><Y>;
say "Even:\t" ~ $adj<Even><X> ~ "\t" ~ $adj<Even><Y>;

blank();

if not $option or $option ne "--pages" {
    say "use --pages to show file information";
}
else {
    say "Pages:";
    for $jdf.ResourcePool.Runlist -> $page {
        printf("%02d: ", $page<Page>);
        print $page<Scaling><X> ~ 'x' ~ $page<Scaling><Y> ~ "\t";
        print $page<Offsets><X> ~ '/' ~ $page<Offsets><Y> ~ "\t";
        print "CENTERED" if $page<Centered>;
        say "";
    }
}

sub unurl($s) {
    return $s.subst(/ \%(\w\w) /, { chr <0x> ~ $0.Str }, :g);
}

sub blank {
    say '';
}

# vim: ft=perl6
