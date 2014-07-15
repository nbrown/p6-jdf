use v6;
use Test;
use Jdf;

is Jdf::mm(14.1732), 5.0, 'convert points to mm';
is Jdf::mm("14.1732"), 5.0, 'convert str points to mm';
is Jdf::mm(-14.1732), -5.0, 'convert negative points to mm';
is Jdf::mm("-14.1732"), -5.0, 'convert negative str points to mm';
is Jdf::mm(42), 15, 'convert pt to mm';
is Jdf::mm(5), 2, 'pearl';
is Jdf::mm(12), 4, 'pica';
is Jdf::mm(24), 8, 'double pica';
is Jdf::mm(48), 17, 'canon';
is Jdf::mm(72), (25.4).round, '1 inch';

my Jdf $jdf = Jdf.new(slurp('t/TestJobFile.jdf'));

is $jdf.AuditPool.Created<AgentName>, 'Kodak Preps', 'agent name is correct';
is $jdf.AuditPool.Created<AgentVersion>,'5.3.3  (595)','agent version correct';
# 2014-07-02T04:55:31+12:45
is $jdf.AuditPool.Created<TimeStamp>, DateTime.new(
    year => 2014, month => 7, day => 2, hour => 4, minute => 55, second => 31,
    timezone => ((12 * 60) + 45) * 60), 'timestamp correct'
