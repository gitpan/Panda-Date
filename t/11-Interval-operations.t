use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/date rdate idate :const/;

my $idate;
##################################### check ops table #######################################

# +
$idate = idate("2012-02-01", "2013-02-01");
ok(($idate + "1D") eq ["2012-02-02", "2013-02-02"]); # $idate $scalar
ok("1Y" + $idate == [[2013,2,1], [2014,2,1]]); # $scalar $idate
ok($idate + 28*DAY eq ["2012-02-29", "2013-03-01"]); # $idate $rel
ok(!eval {my $a = $idate + date(0); 1}); # $idate $date
ok(!eval {my $a = $idate + $idate; 1}); # $idate $idate

# +=
$idate = idate("2012-02-01", "2013-02-01");
# $idate $scalar
$idate += "1D";
ok($idate eq ["2012-02-02", "2013-02-02"]);
# $scalar $idate
my $scalar = "1Y";
$scalar += $idate;
ok($idate eq ["2012-02-02", "2013-02-02"]);
ok($scalar eq ["2013-02-02", "2014-02-02"]);
# $idate $rel
$idate += HOUR;
ok($idate eq ["2012-02-02 01:00:00", "2013-02-02 01:00:00"]);
ok(HOUR eq "1h");
# $idate $date
ok(!eval { $idate += date(123); 1; });
# $idate $idate
ok(!eval { $idate += idate(123,123); 1; });

# -
$idate = idate("2012-02-01", "2013-02-01");
ok($idate - "1D" eq ["2012-01-31", "2013-01-31"]); # $idate $scalar
ok(!eval {my $a = "1Y" - $idate; 1}); # $scalar $idate
ok($idate - DAY eq ["2012-01-31", "2013-01-31"]); # $idate $rel
ok(!eval { my $a = $idate - date("2012-01-01"); 1; }); # $idate $date
ok(!eval { my $a = $idate - idate(111,111); 1; }); # $idate $idate

# -=
$idate = idate("2012-02-01", "2013-02-01");
# $idate $scalar
$idate -= "1M";
ok($idate eq ["2012-01-01", "2013-01-01"]);
# $scalar $idate
$scalar = "23h";
ok(!eval { $scalar -= $idate; 1});
# $idate $rel
$idate -= DAY;
ok($idate eq ["2011-12-31", "2012-12-31"]);
ok(DAY eq "1D");
# $idate $date
ok(!eval { $idate -= date(123); 1; });
# $idate $idate
ok(!eval { $idate -= idate(123,123); 1; });

# - unary
$idate = idate("2012-02-01", "2013-02-01");
ok($idate->duration == 31622400);
ok((-$idate)->duration == -31622400);
$idate->negative_me;
ok($idate->duration == -31622400);

# <=>
$idate = idate("2012-02-01 00:00:00", "2012-02-01 00:00:01");
# $idate $scalar
ok($idate > ["2013-02-01 00:00:00", "2013-02-01 00:00:00"] and $idate < ["2013-02-01 00:00:00", "2013-02-01 00:00:02"]);
ok($idate == ["2013-02-01 00:00:00", "2013-02-01 00:00:01"] and $idate ne ["2013-02-01 00:00:00", "2013-02-01 00:00:01"]);
ok($idate eq ["2012-02-01 00:00:00", "2012-02-01 00:00:01"]);
ok($idate > 0 and $idate < 2 and $idate == 1);
# $scalar $idate
ok(["2013-02-01 00:00:00", "2013-02-01 00:00:00"] < $idate and ["2013-02-01 00:00:00", "2013-02-01 00:00:02"] > $idate);
ok(["2013-02-01 00:00:00", "2013-02-01 00:00:01"] == $idate and ["2013-02-01 00:00:00", "2013-02-01 00:00:01"] ne $idate);
ok(["2012-02-01 00:00:00", "2012-02-01 00:00:01"] eq $idate);
ok(0 < $idate and 2 > $idate and 1 == $idate);
# $idate $rel
ok(!eval {my $a = $idate > DAY; 1});
# $idate $date
ok(!eval {my $a = $idate < date(0); 1});
# $idate $idate
ok($idate > idate("2013-02-01 00:00:00", "2013-02-01 00:00:00") and $idate < idate("2013-02-01 00:00:00", "2013-02-01 00:00:02"));
ok($idate == idate("2013-02-01 00:00:00", "2013-02-01 00:00:01") and $idate ne idate("2013-02-01 00:00:00", "2013-02-01 00:00:01"));
ok($idate eq idate("2012-02-01 00:00:00", "2012-02-01 00:00:01"));

#check that rdates haven't been changed
ok(SEC eq '1s' and MIN eq '1m' and HOUR eq '1h' and DAY eq '1D' and MONTH eq '1M' and YEAR eq '1Y');

done_testing();
