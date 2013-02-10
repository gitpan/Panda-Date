use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/rdate :const/;

my $rel;

$rel = new Panda::Date::Rel;
ok($rel->sec == 0 and $rel->min == 0 and $rel->hour == 0 and $rel->day == 0 and $rel->month == 0 and $rel->year == 0);
ok(!$rel and $rel eq "");

$rel = new Panda::Date::Rel(1000);
ok($rel->sec == 1000 and $rel->min == 0 and $rel->hour == 0 and $rel->day == 0 and $rel->month == 0 and $rel->year == 0);
ok($rel eq "1000s" and $rel eq $rel->string and $rel eq $rel->to_string and $rel eq $rel->as_string);
ok($rel->sec == $rel->secs and $rel->sec == $rel->second and $rel->sec == $rel->seconds);

$rel = new Panda::Date::Rel("1000");
ok($rel->sec == 1000 and $rel->min == 0 and $rel->hour == 0 and $rel->day == 0 and $rel->month == 0 and $rel->year == 0);
ok($rel eq "1000s");

$rel = new Panda::Date::Rel [1,2,3,4,5,6];
ok($rel->sec == 6 and $rel->min == 5 and $rel->hour == 4 and $rel->day == 3 and $rel->month == 2 and $rel->year == 1);
ok($rel->to_sec == 37090322 and $rel->to_sec == $rel->to_number and int($rel) == $rel->to_sec);
ok(abs($rel->to_min   - 618172.033333) < 0.000001);
ok(abs($rel->to_hour  -  10302.867222) < 0.000001);
ok(abs($rel->to_day   -    429.286134) < 0.000001);
ok(abs($rel->to_month -     14.104156) < 0.000001);
ok(abs($rel->to_year  -      1.175346) < 0.000001);
ok($rel->to_secs == $rel->to_sec and $rel->to_sec == $rel->to_seconds and $rel->to_sec == $rel->to_second);
ok($rel->to_mins == $rel->to_min and $rel->to_min == $rel->to_minutes and $rel->to_min == $rel->to_minute);
ok($rel->to_hours == $rel->to_hour);
ok($rel->to_days == $rel->to_day);
ok($rel->to_months == $rel->to_month and $rel->to_month == $rel->to_mon and $rel->to_month == $rel->to_mons);
ok($rel eq "1Y 2M 3D 4h 5m 6s");

$rel = new Panda::Date::Rel($rel);
ok($rel eq "1Y 2M 3D 4h 5m 6s");

$rel = new Panda::Date::Rel {year => 1, month => 2, day => 3, hour => 4, min => 5, sec => 6};
ok($rel->sec == 6 and $rel->min == 5 and $rel->hour == 4 and $rel->day == 3 and $rel->month == 2 and $rel->year == 1);
ok($rel eq "1Y 2M 3D 4h 5m 6s");

$rel = new Panda::Date::Rel "6s";
ok($rel eq "6s" and $rel->sec == 6 and $rel->to_sec == 6 and $rel->to_min == 0.1);

$rel = new Panda::Date::Rel "5m";
ok($rel eq "5m" and $rel->min == 5 and $rel->to_sec == 300);

$rel = new Panda::Date::Rel "2h";
ok($rel eq "2h" and $rel->hour == 2 and $rel->to_sec == 7200);

$rel = new Panda::Date::Rel "1s 1m 1h";
ok($rel eq "1h 1m 1s" and $rel->sec == 1 and $rel->min == 1 and $rel->hour == 1 and $rel->to_sec == 3661);

$rel = new Panda::Date::Rel "-9999M";
ok($rel eq "-9999M" and $rel->month == -9999);

$rel = new Panda::Date::Rel "12Y";
ok($rel eq "12Y" and $rel->year == 12);

$rel = new Panda::Date::Rel "1Y 2M 3D 4h 5m 6s";
ok($rel->sec == 6 and $rel->min == 5 and $rel->hour == 4 and $rel->day == 3 and $rel->month == 2 and $rel->year == 1);
ok($rel eq "1Y 2M 3D 4h 5m 6s");

$rel = new Panda::Date::Rel "-1Y -2M -3D 4h 5m 6s";
ok($rel eq "-1Y -2M -3D 4h 5m 6s");
ok($rel->sec == 6 and $rel->min == 5 and $rel->hour == 4 and $rel->day == -3 and $rel->month == -2 and $rel->year == -1);

$rel = rdate "1Y 2M 3D 4h 5m 6s";
ok($rel->sec == 6 and $rel->min == 5 and $rel->hour == 4 and $rel->day == 3 and $rel->month == 2 and $rel->year == 1);
ok($rel eq "1Y 2M 3D 4h 5m 6s");

ok(rdate("2012-03-02 15:47:32", "2013-04-03 16:48:33") eq "1Y 1M 1D 1h 1m 1s");
ok(rdate("2013-04-03 16:48:33", "2012-03-02 15:47:32") eq "-1Y -1M -1D -1h -1m -1s");
ok(rdate("2012-03-02 15:47:32", "2013-04-03 16:48:33") eq Panda::Date::Rel->new("2012-03-02 15:47:32", "2013-04-03 16:48:33"));

$rel->set_from(1000);
ok($rel eq "1000s");
$rel->set_from(0);
$rel->set_from("1000");
ok($rel eq "1000s");
$rel->set_from(0);
$rel->set_from("1Y 2M 3D 4h 5m 6s");
ok($rel eq "1Y 2M 3D 4h 5m 6s");
$rel->set_from(0);
$rel->set_from([1,2,3,4,5,6]);
ok($rel eq "1Y 2M 3D 4h 5m 6s");
$rel->set_from(0);
$rel->set_from({year => 1, month => 2, day => 3, hour => 4, min => 5, sec => 6});
ok($rel eq "1Y 2M 3D 4h 5m 6s");
$rel->set_from(0);

ok(SEC eq "1s");
ok(MIN eq "1m");
ok(HOUR eq "1h");
ok(DAY eq '1D');
ok(MONTH eq '1M');
ok(YEAR eq '1Y');

done_testing();
