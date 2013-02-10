use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date;

# OK
my $date = new Panda::Date("2010-01-01");
my $ok;
$ok = 1 if $date;
ok($ok and $date and $date->error == E_OK);

# UNPARSABLE
$date = new Panda::Date("pizdec");
$ok = 0;
$ok = 1 if $date;
ok(!$ok and !$date);
ok($date->error == E_UNPARSABLE and $date->errstr);
ok(int($date) == 0);

done_testing();
