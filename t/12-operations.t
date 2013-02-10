use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/now today date rdate :const/;

my $date;

##################### COMPARE ###########################
$date = date(1000);
ok($date > 0);
ok($date > 999);
ok($date >= 1000);
ok($date < 1001);
ok($date > "1970-01-01 03:16:00");
ok($date > [1970,1,1,3,16]);
ok($date < "1970-01-01 03:17:00");
ok($date < {year => 1970, month => 1, day => 1, hour => 3, min => 17});
ok($date == "1970-01-01 03:16:40");
ok($date eq "1970-01-01 03:16:40");
ok(date("2013-05-06 01:02:03") < date("2013-05-06 01:02:04"));
ok("2013-05-06 01:02:03" < date("2013-05-06 01:02:04"));
ok(date("2013-05-06 01:02:03") < "2013-05-06 01:02:04");
ok("2013-05-06 01:02:04" == date("2013-05-06 01:02:04"));
ok(date("2001-09-09 05:46:40") == 1000000000);
ok(date("2001-09-09 05:46:40") < 1000000001);
ok(date("2001-09-09 05:46:40") > 999999999);
ok(1000000000 == date("2001-09-09 05:46:40"));
ok(1000000001 > date("2001-09-09 05:46:40"));
ok(999999999 < date("2001-09-09 05:46:40"));

# INVALID COMPARE
ok(!eval{my $a = $date > rdate(10); 1;});
ok(!eval{my $a = rdate(10) > $date; 1;});

#################### ADD RELATIVE DATE ####################
$date = date("2013-01-01");

my $reldate = rdate(0);
ok($date + $reldate == $date);

$reldate = rdate(10);
ok($date + $reldate == "2013-01-01 00:00:10");
ok($date + "15m 60s" == "2013-01-01 00:15:60");
ok($date + "23h 15m 60s" == "2013-01-01 23:15:60");
ok($date + "24h 15m 60s" == "2013-01-02 00:15:60");
ok($date + 10*DAY == "2013-01-11");
ok($date + MONTH == "2013-02-01");
ok($date + 2000*YEAR == "4013-01-01");

$date += "1M";
ok($date == "2013-02-01");
$date += 27*DAY;
ok($date == "2013-02-28");
$date += DAY;
ok($date == "2013-03-01");

$date = date("2012-02-29");
Panda::Date->month_border_adjust(1);
$date += YEAR;
ok($date eq "2013-02-28");
Panda::Date->month_border_adjust(0);


##################################### check ops table #######################################
$date = date("2012-03-02 15:47:32");
# +
ok($date + "1D" == "2012-03-03 15:47:32"); # $date $scalar
ok("1Y 1m" + $date == "2013-03-02 15:48:32"); # $scalar $date
ok($date + HOUR == "2012-03-02 16:47:32"); # $date $rel
ok(!eval {my $a = $date + date(0); 1}); # $date $date
ok(!eval {my $a = $date + idate(0,0); 1}); # $date $idate

# +=
# $date $scalar
$date = date("2012-03-02 15:47:32");
$date += "1M";
ok($date eq "2012-04-02 15:47:32");
# $scalar $date
my $scalar = "23h";
$scalar += $date;
ok($date eq "2012-04-02 15:47:32");
ok($scalar eq "2012-04-03 14:47:32");
# $date $rel
$date += YEAR;
ok($date eq "2013-04-02 15:47:32");
ok(YEAR eq "1Y");
# $date $date
ok(!eval { $date += date(123); 1; });
# $date $idate
ok(!eval { $date += idate(123,123); 1; });

# -
$date = date("2012-03-02 15:47:32");
ok($date - "1D" == "2012-03-01 15:47:32"); # $date $scalar-rel
ok($date - "2011-04-03 16:48:33" eq ["2011-04-03 16:48:33", "2012-03-02 15:47:32"]); # $date $scalar-date
ok("2013-04-03 16:48:33" - $date eq ["2012-03-02 15:47:32", "2013-04-03 16:48:33"]); # $scalar $date
ok($date - HOUR == "2012-03-02 14:47:32"); # $date $rel
ok(date("2013-04-03 16:48:33") - $date eq ["2012-03-02 15:47:32", "2013-04-03 16:48:33"]); # $date $date
ok(!eval { my $a = $date - idate(111,111); 1; }); # $date $idate

# -=
# $date $scalar
$date = date("2012-03-02 15:47:32");
$date -= "1M";
ok($date eq "2012-02-02 15:47:32");
# $scalar $date
$scalar = "2013-04-03 16:48:33";
$scalar -= $date;
ok($date eq "2012-02-02 15:47:32");
ok($scalar eq ["2012-02-02 15:47:32", "2013-04-03 16:48:33"]);
# $date $rel
$date -= DAY;
ok($date eq "2012-02-01 15:47:32");
# $date $date
ok(!eval { $date -= date(123); 1; });
# $date $idate
ok(!eval { $date -= idate(123,123); 1; });

# <=>
$date = date("2012-03-02 15:47:32");
ok($date > "2012-03-02 15:47:31" and $date < "2012-03-02 15:47:33"); # $date $scalar
ok($date > 1330688851 and $date < 1330688853 and $date == 1330688852 and $date eq 1330688852);
ok("2012-03-02 15:47:31" < $date and "2012-03-02 15:47:33" > $date); # $scalar $date
ok(1330688851 < $date and 1330688853 > $date and 1330688852 == $date and 1330688852 eq $date);
ok(!eval { my $a = $date > MONTH; 1}); # $date $rel
ok($date > date(0) and $date < date(2000000000)); # $date $date
ok(date(1330688851) < $date and date(1330688853) > $date and date(1330688852) == $date and date(1330688852) eq $date);
ok(!eval {my $a = $date == idate(0,0); 1}); # $rel $idate

#check that rdates haven't been changed
ok(SEC eq '1s' and MIN eq '1m' and HOUR eq '1h' and DAY eq '1D' and MONTH eq '1M' and YEAR eq '1Y');

done_testing();
