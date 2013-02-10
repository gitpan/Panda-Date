use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/date rdate idate :const/;

my $rel;

ok(SEC eq '1s' and MIN eq '1m' and HOUR eq '1h' and DAY eq '1D' and MONTH eq '1M' and YEAR eq '1Y');

$rel = SEC+MIN+HOUR+DAY+MONTH+YEAR;
ok($rel eq "1Y 1M 1D 1h 1m 1s");
ok( ($rel+10*SEC) eq ($rel+'10s') and ($rel+10*SEC) eq ($rel+[0,0,0,0,0,10]) and ($rel+10*SEC) eq ($rel+{sec=>10}) );
$rel += 10*SEC;
ok($rel eq "1Y 1M 1D 1h 1m 11s");

ok($rel*2 eq "2Y 2M 2D 2h 2m 22s");
$rel *= 2;
ok($rel eq "2Y 2M 2D 2h 2m 22s");

ok($rel/2 eq "1Y 1M 1D 1h 1m 11s");
$rel /= 2;
ok($rel eq "1Y 1M 1D 1h 1m 11s");

ok(($rel - YEAR) eq "1M 1D 1h 1m 11s");
$rel -= YEAR;
ok($rel eq "1M 1D 1h 1m 11s");

ok(!eval {$rel -= date()});
ok(!eval {$rel - date()});

$rel -= [0,1,1];
ok($rel eq "1h 1m 11s");

$rel -= {hour => 1, min => 2, sec => 1};
ok($rel eq "-1m 10s");

ok(YEAR/2 eq "6M");
ok(MONTH/2 eq "15D 5h 14m 32s");
ok(DAY/2 eq "12h");
ok(HOUR/2 eq "30m");
ok(MIN/2 eq "30s");
ok(SEC/2 eq "");
ok(YEAR*0.5 eq "6M");
ok(MONTH*0.5 eq "15D 5h 14m 32s");
ok(DAY*0.5 eq "12h");
ok(HOUR*0.5 eq "30m");
ok(MIN*0.5 eq "30s");
ok(SEC*0.5 eq "");

$rel += $rel;
ok($rel eq "-2m 20s");

$rel = rdate("1Y 3M") + $rel;
ok($rel eq "1Y 3M -2m 20s");

$rel -= $rel;
ok($rel eq "");

ok($rel*2 eq "");

ok($rel*2 == $rel);

$rel = rdate("1Y 2M");
ok($rel > 1000);
ok($rel > "1Y");
ok($rel < "2Y");
ok($rel == "1Y 2M");
ok($rel == "14M" and $rel ne "14M");

ok(!eval {2/YEAR});

# reverse test
ok(('10D' - MONTH) eq "-1M 10D");

my $relstr = '10D';
$relstr -= MONTH; # this is actually not optimized by perl and executes as '$relstr = $relstr - MONTH'
ok(MONTH eq "1M");
ok($relstr eq "-1M 10D");

##################################### check ops table #######################################

# +
ok(MONTH + "1D" == "1M 1D"); # $rel $scalar
ok("1Y" + DAY == "1Y 1D"); # $scalar $rel
ok(YEAR + HOUR == '1Y 1h'); # $rel $rel
ok( (MONTH + date("2012-01-01")) eq "2012-02-01" ); # $rel $date
ok( (DAY + idate("2012-01-01", "2012-06-01")) eq idate("2012-01-02", "2012-06-02") ); # $rel $idate

# +=
# $rel $scalar
$rel = rdate("1Y 1M");
$rel += "1M";
ok($rel eq "1Y 2M");
# $scalar $rel
my $scalar = "23h";
$scalar += $rel;
ok($rel eq "1Y 2M");
ok($scalar eq "1Y 2M 23h");
# $rel $rel
$rel += DAY;
ok($rel eq "1Y 2M 1D");
ok(DAY eq "1D");
# $rel $date
ok(!eval { $rel += date(123); 1; });
# $rel $idate
ok(!eval { $rel += idate(123,123); 1; });

# -
ok(MONTH - "1D" == "1M -1D"); # $rel $scalar
ok("1Y" - DAY == "1Y -1D"); # $scalar $rel
ok(YEAR - HOUR == '1Y -1h'); # $rel $rel
ok(!eval { my $a = MONTH - date("2012-01-01"); 1; }); # $rel $date
ok(!eval { my $a = DAY - idate(111,111); 1; }); # $rel $idate

# -=
# $rel $scalar
$rel = rdate("1Y 1M");
$rel -= "1M";
ok($rel eq "1Y");
# $scalar $rel
$scalar = "23h";
$scalar -= $rel;
ok($rel eq "1Y");
ok($scalar eq "-1Y 23h");
# $rel $rel
$rel -= DAY;
ok($rel eq "1Y -1D");
# $rel $date
ok(!eval { $rel -= date(123); 1; });
# $rel $idate
ok(!eval { $rel -= idate(123,123); 1; });

# *
ok(MONTH*5 == "5M"); # $rel $scalar
ok(100*DAY == "100D"); # $scalar $rel
ok(!eval {my $a = DAY*DAY;1}); # $rel $rel
ok(!eval {my $a = DAY*date(0);1}); # $rel $date
ok(!eval {my $a = DAY*idate(0,0);1}); # $rel $idate

# *=
# $rel $scalar
$rel = rdate("100Y 2M");
$rel *= 0.5;
ok($rel eq "50Y 1M");
# $scalar $rel
$scalar = 10;
$scalar *= $rel;
ok($rel eq "50Y 1M");
ok($scalar eq "500Y 10M");
# $rel $rel
ok(!eval {$rel *= $rel; 1});
# $rel $date
ok(!eval {$rel *= date(0); 1});
# $rel $idate
ok(!eval {$rel *= idate(0,0); 1});

# /
ok(DAY/4 == "6h"); # $rel $scalar
ok(!eval {my $a = 2/SEC; 1}); # $scalar $rel
ok(!eval {my $a = DAY*DAY; 1}); # $rel $rel
ok(!eval {my $a = DAY*date(0); 1}); # $rel $date
ok(!eval {my $a = DAY*idate(0,0); 1}); # $rel $idate

# /=
# $rel $scalar
$rel = rdate("100Y 2M");
$rel /= 0.5;
ok($rel eq "200Y 4M");
# $scalar $rel
$scalar = 10;
ok(!eval {$scalar /= $rel; 1});
# $rel $rel
ok(!eval {$rel /= $rel; 1});
# $rel $date
ok(!eval {$rel /= date(0); 1});
# $rel $idate
ok(!eval {$rel /= idate(0,0); 1});

# - unary
ok(-rdate("1Y 2M -3D -4h") eq "-1Y -2M 3D 4h");

# <=>
$rel = rdate("1Y 1M");
ok($rel > "1Y" and $rel < "1Y 1M 1s"); # $rel $scalar
ok("1Y" < $rel and "1Y 1M 1s" > $rel); # $scalar $rel
ok(!($rel > $rel) and !($rel < $rel) and $rel == $rel and $rel > rdate("1Y") and $rel != rdate("1Y 30M")); # $rel $rel
ok(!eval {my $a = $rel < date(0); 1}); # $rel $date
ok(!eval {my $a = $rel == idate(0,0); 1}); # $rel $idate

#check that rdates haven't been changed
ok(SEC eq '1s' and MIN eq '1m' and HOUR eq '1h' and DAY eq '1D' and MONTH eq '1M' and YEAR eq '1Y');

done_testing();
