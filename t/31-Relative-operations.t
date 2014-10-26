use 5.012;
use warnings;
use Test::More;
use lib 't/lib'; use PDTest;

my $rel;

is(SEC, '1s');
is(MIN, '1m');
is(HOUR, '1h');
is(DAY, '1D');
is(MONTH, '1M');
is(YEAR, '1Y');

$rel = SEC+MIN+HOUR+DAY+MONTH+YEAR;
is($rel, "1Y 1M 1D 1h 1m 1s");
is($rel + 10*SEC, $rel + '10s');
is($rel + 10*SEC, $rel + [0,0,0,0,0,10]);
is($rel + 10*SEC, $rel + {sec => 10});
$rel += 10*SEC;
is($rel, "1Y 1M 1D 1h 1m 11s");

is($rel*2, "2Y 2M 2D 2h 2m 22s");
$rel *= 2;
is($rel, "2Y 2M 2D 2h 2m 22s");

is($rel/2, "1Y 1M 1D 1h 1m 11s");
$rel /= 2;
is($rel, "1Y 1M 1D 1h 1m 11s");

is($rel - YEAR, "1M 1D 1h 1m 11s");
$rel -= YEAR;
is($rel, "1M 1D 1h 1m 11s");

ok(!eval {$rel -= date()});
ok(!eval {$rel - date()});

$rel -= [0,1,1];
is($rel, "1h 1m 11s");

$rel -= {hour => 1, min => 2, sec => 1};
is($rel, "-1m 10s");

is(YEAR/2, "6M");
is(MONTH/2, "15D 5h 14m 32s");
is(DAY/2, "12h");
is(HOUR/2, "30m");
is(MIN/2, "30s");
is(SEC/2, "");
is(YEAR*0.5, "6M");
is(MONTH*0.5, "15D 5h 14m 32s");
is(DAY*0.5, "12h");
is(HOUR*0.5, "30m");
is(MIN*0.5, "30s");
is(SEC*0.5, "");

$rel += $rel;
is($rel, "-2m 20s");

$rel = rdate("1Y 3M") + $rel;
is($rel, "1Y 3M -2m 20s");

$rel -= $rel;
is($rel, "");

is($rel*2, "");

cmp_ok($rel*2, '==', $rel);

$rel = rdate("1Y 2M");
cmp_ok($rel, '>', 1000);
cmp_ok($rel, '>', "1Y");
cmp_ok($rel, '<', "2Y");
cmp_ok($rel, '==', "1Y 2M");
cmp_ok($rel, '==', "14M");
isnt($rel, "14M");

ok(!eval {2/YEAR});

# reverse test
is('10D' - MONTH, "-1M 10D");

my $relstr = '10D';
$relstr -= MONTH; # this is actually not optimized by perl and executes as '$relstr = $relstr - MONTH'
is(MONTH, "1M");
is($relstr, "-1M 10D");

##################################### check ops table #######################################

# +
cmp_ok(MONTH + "1D", '==', "1M 1D"); # $rel $scalar
cmp_ok("1Y" + DAY, '==', "1Y 1D"); # $scalar $rel
cmp_ok(YEAR + HOUR, '==', '1Y 1h'); # $rel $rel
is(MONTH + date("2012-01-01"), "2012-02-01"); # $rel $date
is(DAY + idate("2012-01-01", "2012-06-01"), idate("2012-01-02", "2012-06-02")); # $rel $idate

# +=
# $rel $scalar
$rel = rdate("1Y 1M");
$rel += "1M";
is($rel, "1Y 2M");
# $scalar $rel
my $scalar = "23h";
$scalar += $rel;
is($rel, "1Y 2M");
is($scalar, "1Y 2M 23h");
# $rel $rel
$rel += DAY;
is($rel, "1Y 2M 1D");
is(DAY, "1D");
# $rel $date
ok(!eval { $rel += date(123); 1; });
# $rel $idate
ok(!eval { $rel += idate(123,123); 1; });

# -
cmp_ok(MONTH - "1D", '==', "1M -1D"); # $rel $scalar
cmp_ok("1Y" - DAY, '==', "1Y -1D"); # $scalar $rel
cmp_ok(YEAR - HOUR, '==', '1Y -1h'); # $rel $rel
ok(!eval { my $a = MONTH - date("2012-01-01"); 1; }); # $rel $date
ok(!eval { my $a = DAY - idate(111,111); 1; }); # $rel $idate

# -=
# $rel $scalar
$rel = rdate("1Y 1M");
$rel -= "1M";
is($rel, "1Y");
# $scalar $rel
$scalar = "23h";
$scalar -= $rel;
is($rel, "1Y");
is($scalar, "-1Y 23h");
# $rel $rel
$rel -= DAY;
is($rel, "1Y -1D");
# $rel $date
ok(!eval { $rel -= date(123); 1; });
# $rel $idate
ok(!eval { $rel -= idate(123,123); 1; });

# *
cmp_ok(MONTH*5, '==', "5M"); # $rel $scalar
cmp_ok(100*DAY, '==', "100D"); # $scalar $rel
ok(!eval {my $a = DAY*DAY;1}); # $rel $rel
ok(!eval {my $a = DAY*date(0);1}); # $rel $date
ok(!eval {my $a = DAY*idate(0,0);1}); # $rel $idate

# *=
# $rel $scalar
$rel = rdate("100Y 2M");
$rel *= 0.5;
is($rel, "50Y 1M");
# $scalar $rel
$scalar = 10;
$scalar *= $rel;
is($rel, "50Y 1M");
is($scalar, "500Y 10M");
# $rel $rel
ok(!eval {$rel *= $rel; 1});
# $rel $date
ok(!eval {$rel *= date(0); 1});
# $rel $idate
ok(!eval {$rel *= idate(0,0); 1});

# /
cmp_ok(DAY/4, '==', "6h"); # $rel $scalar
ok(!eval {my $a = 2/SEC; 1}); # $scalar $rel
ok(!eval {my $a = DAY*DAY; 1}); # $rel $rel
ok(!eval {my $a = DAY*date(0); 1}); # $rel $date
ok(!eval {my $a = DAY*idate(0,0); 1}); # $rel $idate

# /=
# $rel $scalar
$rel = rdate("100Y 2M");
$rel /= 0.5;
is($rel, "200Y 4M");
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
is(-rdate("1Y 2M -3D -4h"), "-1Y -2M 3D 4h");

# <=>
$rel = rdate("1Y 1M");
cmp_ok($rel, '>', "1Y"); # $rel $scalar
cmp_ok($rel, '<', "1Y 1M 1s"); # $rel $scalar
cmp_ok("1Y", '<', $rel); # $scalar $rel
cmp_ok("1Y 1M 1s", '>', $rel); # $scalar $rel
ok(!($rel > $rel), "!($rel > $rel)"); # $rel $rel
ok(!($rel < $rel), "!($rel < $rel)"); # $rel $rel
cmp_ok($rel, '==', $rel); # $rel $rel
cmp_ok($rel, '>', rdate("1Y")); # $rel $rel
cmp_ok($rel, '!=', rdate("1Y 30M")); # $rel $rel
ok(!eval {my $a = $rel < date(0); 1}); # $rel $date
ok(!eval {my $a = $rel == idate(0,0); 1}); # $rel $idate

#check that rdates haven't been changed
is(SEC, '1s');
is(MIN, '1m');
is(HOUR, '1h');
is(DAY, '1D');
is(MONTH, '1M');
is(YEAR, '1Y');

done_testing();
