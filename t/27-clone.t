use 5.012;
use warnings;
use Test::More;
use lib 't/lib'; use PDTest;

my ($date, $date2, $date3);

$date = date('2014-01-01 00:00:00');
ok($date->tzlocal);
is($date->tzname, tzget()->{name});

$date2 = $date->clone;
is($date2, $date);
ok($date2->tzlocal);
is($date2->tzname, tzget()->{name});

$date2 = $date->clone(undef, 'Australia/Melbourne');
isnt($date2->epoch, $date->epoch);
is($date2.'', $date.'');
ok(!$date2->tzlocal);
is($date2->tzname, 'Australia/Melbourne');

$date3 = $date2->clone([-1, -1, -1, 1, 2, 3]);
is($date3, "2014-01-01 01:02:03");
is($date3->tzname, $date2->tzname);

$date3 = $date3->clone({year => 2013, day => 10});
is($date3, "2013-01-10 01:02:03");
is($date3->tzname, $date2->tzname);

$date3 = $date3->clone({month => 2}, "");
is($date3, "2013-02-10 01:02:03");
isnt($date3->tzname, $date2->tzname);
ok($date3->tzlocal);
is($date3->tzname, tzget()->{name});

$date2 = $date->clone({year => 1700, tz => 'Europe/Kiev'});
is($date2, "1700-01-01");
ok(!$date2->tzlocal);
is($date2->tzname, 'Europe/Kiev');

done_testing();
