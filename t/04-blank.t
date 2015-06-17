use v6;
use Test;
use Printing::Jdf;

plan 1;

my Printing::Jdf $jdf = Printing::Jdf.new(slurp('t/BlankPageTest.jdf'));

my $runlist = $jdf.ResourcePool.Runlist;
my $page2 = $runlist[2 - 1];

is $page2<Url>.basename, 'Blank Page';

# vim: ft=perl6
