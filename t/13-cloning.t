use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date qw/now today date idate rdate :const/;
use Storable qw/freeze nfreeze dclone thaw/;

# This test checks the ability to be cloned by various serializing/cloning frameworks.

my ($date_cloned, $rdate_cloned, $idate_cloned);
my @a;

# Storable
$date_cloned = thaw(freeze date("2012-01-01 15:16:17"));
ok($date_cloned->to_string eq "2012-01-01 15:16:17");
$date_cloned = thaw(nfreeze date("2012-01-01 15:16:17"));
ok($date_cloned->to_string eq "2012-01-01 15:16:17");
$date_cloned = dclone date("2012-01-01 15:16:17");
ok($date_cloned->to_string eq "2012-01-01 15:16:17");

$rdate_cloned = thaw(freeze rdate("1Y 1M"));
ok($rdate_cloned->to_string eq "1Y 1M");
$rdate_cloned = thaw(nfreeze rdate("1Y 1M"));
ok($rdate_cloned->to_string eq "1Y 1M");
$rdate_cloned = dclone rdate("1Y 1M");
ok($rdate_cloned->to_string eq "1Y 1M");

$idate_cloned = thaw(freeze idate("2012-01-01 15:16:17", "2013-01-01 15:16:17"));
ok($idate_cloned->to_string eq "2012-01-01 15:16:17 ~ 2013-01-01 15:16:17");
$idate_cloned = thaw(nfreeze idate("2012-01-01 15:16:17", "2013-01-01 15:16:17"));
ok($idate_cloned->to_string eq "2012-01-01 15:16:17 ~ 2013-01-01 15:16:17");
$idate_cloned = dclone idate("2012-01-01 15:16:17", "2013-01-01 15:16:17");
ok($idate_cloned->to_string eq "2012-01-01 15:16:17 ~ 2013-01-01 15:16:17");

done_testing();
