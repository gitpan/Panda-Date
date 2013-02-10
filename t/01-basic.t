use 5.012;
use warnings;
use Test::More;
use Test::Deep;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date;

my $date = new Panda::Date(0);
ok($date->epoch == 0);
ok($date->year == 1970 and $date->_year == 70 and $date->yr == 70);
ok($date->month == 1 and $date->mon == 1 and $date->_month == 0 and $date->_mon == 0);
ok($date->day == 1 and $date->mday == 1 and $date->day_of_month == 1);
ok($date->hour == 3 and $date->min == 0 and $date->minute == 0 and $date->sec == 0 and $date->second == 0);
ok($date->to_string eq "1970-01-01 03:00:00");

$date = new Panda::Date(1000000000);
ok($date->to_string eq "2001-09-09 05:46:40" and $date->_year == 101 and $date->yr == 1);
ok($date eq $date->to_string and $date eq $date->string and $date eq $date->as_string);
ok($date->to_number == 1000000000 and int($date) == $date->to_number);

$date = new Panda::Date($date);
ok($date->epoch == 1000000000);

$date = new Panda::Date([2012,02,20,15,16,17]);
ok($date eq "2012-02-20 15:16:17");
$date = new Panda::Date([2012,02,20,15,16]);
ok($date eq "2012-02-20 15:16:00");
$date = new Panda::Date([2012,02,20,15]);
ok($date eq "2012-02-20 15:00:00");
$date = new Panda::Date([2012,02,20]);
ok($date eq "2012-02-20 00:00:00");
$date = new Panda::Date([2012,02]);
ok($date eq "2012-02-01 00:00:00");
$date = new Panda::Date([2012]);
ok($date eq "2012-01-01 00:00:00");
$date = new Panda::Date([]);
ok($date eq "2000-01-01 00:00:00");

$date = new Panda::Date({year => 2013, month => 06, day => 28, hour => 6, min => 6, sec => 6});
ok($date eq "2013-06-28 06:06:06");
$date = new Panda::Date({month => 06, day => 28, hour => 6, min => 6, sec => 6});
ok($date eq "2000-06-28 06:06:06");
$date = new Panda::Date({month => 06, hour => 6, min => 6, sec => 6});
ok($date eq "2000-06-01 06:06:06");
$date = new Panda::Date({month => 06, sec => 6});
ok($date eq "2000-06-01 00:00:06");
$date = new Panda::Date({});
ok($date eq "2000-01-01 00:00:00");

$date = new Panda::Date("2013-01-26 6:47:29\0");
ok($date->yr == 13 and $date->month == 1 and $date->mday == 26 and $date->hour == 6 and $date->min == 47 and $date->sec == 29);
ok($date eq "2013-01-26 06:47:29");
$date = new Panda::Date("2013-01-26 6:47:29\n");
ok($date eq "2013-01-26 06:47:29");
$date = new Panda::Date("2013-01-26 6:47:29.345341");
ok($date eq "2013-01-26 06:47:29");

$date = new Panda::Date("2013-02-26 6:47:");
ok($date eq "2013-02-26 06:47:00");
$date = new Panda::Date("2013-02-26 6:47");
ok($date eq "2013-02-26 06:47:00");
$date = new Panda::Date("2013-02-26 6:");
ok($date eq "2013-02-26 06:00:00");
$date = new Panda::Date("2013-02-26 6");
ok($date eq "2013-02-26 06:00:00");
$date = new Panda::Date("2013-02-26 ");
ok($date eq "2013-02-26 00:00:00");
$date = new Panda::Date("2013-02-");
ok($date eq "2013-02-01 00:00:00");
$date = new Panda::Date("2013-02");
ok($date eq "2013-02-01 00:00:00");
$date = new Panda::Date("2013-");
ok($date eq "2013-01-01 00:00:00");
$date = new Panda::Date("2013");
ok($date eq "1970-01-01 03:33:33");

$date = Panda::Date->new("2013-03-05 23:45:56");
ok($date->wday == 3 and $date->_wday == 2 and $date->day_of_week == 3 and $date->ewday == 2);
ok($date->yday == 64 and $date->day_of_year == 64 and $date->_yday == 63);
ok(!$date->isdst and !$date->daylight_savings);
$date = Panda::Date->new("2013-03-10 23:45:56");
ok($date->wday == 1 and $date->_wday == 0 and $date->day_of_week == 1 and $date->ewday == 7);

$ENV{TZ} = 'Europe/Kiev'; POSIX::tzset();
$date = Panda::Date->new("2013-09-05 23:45:56");
ok($date->isdst and $date->daylight_savings);
ok($date->tz eq 'EET' and $date->tzdst eq 'EEST');
$ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();

done_testing();
