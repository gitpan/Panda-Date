use 5.012;
use warnings;
use Test::More;
use lib 't/lib'; use PDTest;

my $date = Panda::Date->new("2013-03-05 2:4:6");
ok(!eval{$date->strftime; 1;});
ok(!$date->strftime(""));
is($date->strftime('%Y'), '2013');
is($date->strftime('%Y/%m/%d'), '2013/03/05');
is($date->strftime('%H-%M-%S'), '02-04-06');
is($date->strftime('%b %B'), 'Mar March');
is($date->monname, 'March');
is($date->monthname, $date->monname);
is($date->wdayname, 'Tuesday');
is($date->wdayname, $date->day_of_weekname);

done_testing();
