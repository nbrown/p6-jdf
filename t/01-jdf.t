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
