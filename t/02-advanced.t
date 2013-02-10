use 5.012;
use warnings;
use Test::More;
use Test::Deep;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/now date today/;

my $date;

$date = Panda::Date->new("2013-09-05 3:4:5");
ok($date->hms eq '03:04:05');
ok($date->ymd eq '2013/09/05');
ok($date->mdy eq '09/05/2013');
ok($date->dmy eq '05/09/2013');
ok($date->ampm eq 'AM');
ok($date->meridiam eq '03:04 AM');

$date = Panda::Date->new("2013-09-05 23:4:5");
ok($date->ampm eq 'PM');
ok($date->meridiam eq '11:04 PM');
ok($date->tzoffset == 14400);

$ENV{TZ} = 'America/New_York'; POSIX::tzset();
$date = Panda::Date->new("2013-09-05 23:45:56");
ok($date->tzoffset == -14400);
$ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();

$date = Panda::Date->new("2013-09-05 3:4:5");
my @ret = $date->array;
ok($ret[0] == 2013 and $ret[1] == 9 and $ret[2] == 5 and $ret[3] == 3 and $ret[4] == 4 and $ret[5] == 5);
cmp_deeply($date->aref, [2013,9,5,3,4,5]);

@ret = $date->struct;
ok($ret[0] == 5 && $ret[1] == 4 && $ret[2] == 3 && $ret[3] == 5 && $ret[4] == 8 && $ret[5] == 113 &&
   $ret[6] == 4 && $ret[7] == 247 && $ret[8] == 0);
cmp_deeply($date->sref, [5,4,3,5,8,113,4,247,0]);

my %ret = $date->hash;
cmp_deeply(\%ret, {year => 2013, month => 9, day => 5, hour => 3, min => 4, sec => 5});
cmp_deeply($date->href, \%ret);

ok($date->month_begin eq "2013-09-01 03:04:05");
ok($date->month_end eq "2013-09-30 03:04:05");
ok($date->days_in_month == 30);

$date = Panda::Date->new("2013-08-05 3:4:5");
ok($date->month_begin eq "2013-08-01 03:04:05" and $date eq "2013-08-05 03:04:05");
ok($date->month_end eq "2013-08-31 03:04:05" and $date eq "2013-08-05 03:04:05");
ok($date->days_in_month == 31);
$date->month_begin_me;
ok($date eq "2013-08-01 03:04:05");
$date->month_end_me;
ok($date eq "2013-08-31 03:04:05");

$date = Panda::Date->new("2013-02-05 3:4:5");
ok($date->month_begin eq "2013-02-01 03:04:05");
ok($date->month_end eq "2013-02-28 03:04:05");
ok($date->days_in_month == 28);

$date = Panda::Date->new("2012-02-05 3:4:5");
ok($date->month_begin eq "2012-02-01 03:04:05");
ok($date->month_end eq "2012-02-29 03:04:05");
ok($date->days_in_month == 29);

# now
my $now = now();
ok(abs($now->epoch - time) <= 1);
# today
$date = today();
ok($date->year == $now->year and $date->month == $now->month and $date->day == $now->day and $date->hour == 0 and $date->min == 0 and $date->sec == 0);

# date
$date = date(0);
ok($date eq "1970-01-01 03:00:00");
$date = date 1000000000;
ok($date eq "2001-09-09 05:46:40");
$date = date [2012,02,20,15,16,17];
ok($date eq "2012-02-20 15:16:17");
$date = date {year => 2013, month => 06, day => 28, hour => 6, min => 6, sec => 6};
ok($date eq "2013-06-28 06:06:06");
$date = date "2013-01-26 6:47:29.345341";
ok($date eq "2013-01-26 06:47:29");

# truncate
$date = date "2013-01-26 6:47:29";
my $date2 = $date->truncate;
ok($date eq "2013-01-26 06:47:29" and $date2 eq "2013-01-26 00:00:00");
$date->truncate_me;
ok($date eq "2013-01-26 00:00:00");

# to_number
ok(int(date(123456789)) == 123456789);

# set_from
$date->set_from(10);
ok($date eq "1970-01-01 03:00:10");
$date->set_from("2970-01-01 03:00:10");
ok($date eq "2970-01-01 03:00:10");
$date->set_from([2010,5,6,7,8,9]);
ok($date eq "2010-05-06 07:08:09");
$date->set_from({year => 2013, hour => 23});
ok($date eq "2013-01-01 23:00:00");

# big years
$date = date("85678-01-01");
ok($date->year == 85678);
ok($date eq "85678-01-01");
ok($date->string eq "85678-01-01 00:00:00");

done_testing();
