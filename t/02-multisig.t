use v6;
use Test;
use Jdf;

my $jdf = Jdf.new(slurp('t/MultiSigTest.jdf'));

is $jdf.ResourcePool.Layout<Signatures>.elems, 5;
is $jdf.ResourcePool.Layout<Signatures>[3 - 1]<PressRun>, 3;

# vim: ft=perl6
