use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/idate date :const/;

my $rel;
my $i;

$i = new Panda::Date::Int(0, 0);
ok($i->from == "1970-01-01 03:00:00" and $i->till == "1970-01-01 03:00:00");
ok($i->duration == 0 and $i->sec == 0 and $i->min == 0 and $i->hour == 0 and $i->day == 0 and $i->month == 0 and $i->year == 0);

$i = idate(1000000000, 1100000000);
ok($i->from == "2001-09-09 05:46:40" and $i->till == "2004-11-09 14:33:20");
ok($i->to_string eq "2001-09-09 05:46:40 - 2004-11-09 14:33:20");
ok($i.'' eq $i->to_string and $i->string eq $i->to_string and $i->as_string eq $i->to_string and $i.'' eq "$i");
ok($i->duration == 100000000 and $i->sec == 100000000 and $i->secs == $i->sec and $i->second == $i->sec and $i->seconds == $i->sec);
ok($i->imin == 1666666 and $i->imins == $i->imin and $i->iminute == $i->imin and $i->iminutes == $i->imin);
ok(abs($i->min-1666666.666666) < 0.000001 and $i->min == $i->mins and $i->min == $i->minute and $i->min == $i->minutes);
ok($i->ihour == 27777 and $i->ihours == $i->ihour);
ok(abs($i->hour-27777.777777) < 0.000001 and $i->hours == $i->hour);
ok($i->iday == 1157 and $i->idays == $i->iday);
ok(abs($i->day - 1157.36574) < 0.000001 and $i->day == $i->days);
ok($i->imonth == 38 and $i->imon == $i->imonth and $i->imons == $i->imon and $i->imonths == $i->imon);
ok(abs($i->month - 38.012191) < 0.000001 and $i->months == $i->month and $i->mon == $i->month and $i->mon == $i->mons);
ok($i->iyear == 3 and $i->iyears == $i->iyear);
ok(abs($i->year - 3.167682) < 0.000001 and $i->years == $i->year);
ok($i->relative eq "3Y 2M 8h 46m 40s");

$i = idate(date(1000000000), date(1100000000));
ok($i->relative eq "3Y 2M 8h 46m 40s");

$i = idate("2001-09-09 22:59:59","2001-09-10 01:00:00");
ok($i->iday == 0 and abs($i->day - 0.083344) < 0.000001);

is(idate("2004-09-10","2004-11-10 00:00:00")->relative, "2M");
is(idate("2004-09-10","2004-11-09 00:00:00")->relative, "1M 30D");
is(idate("2004-09-10","2005-02-09 00:00:00")->relative, "4M 30D");
is(idate("2004-09-10","2005-01-09 00:00:00")->relative, "3M 30D");
is(idate("2004-09-10","2005-03-09 00:00:00")->relative, "5M 27D");
is(idate("2003-09-10","2004-03-09 00:00:00")->relative, "5M 28D");
is(idate("2004-03-09 00:00:00", "2003-09-10")->relative, "-5M -28D");

$i->set_from("1985-01-02 01:02:03", "1990-02-29 23:23:23");
ok($i eq [{year => 1985, month => 1, day => 2, hour => 1, min => 2, sec => 3}, "1990-02-29 23:23:23"]);

done_testing();
