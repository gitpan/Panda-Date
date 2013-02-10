use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date;

Panda::Date->string_format("%Y-%m-%d");

my $date = Panda::Date->new("2001-01-31");
ok(!Panda::Date->month_border_adjust);
$date->month($date->month+1);
ok($date eq "2001-03-03");
ok($date->yday == 62);
ok($date->ewday == 6);

$date = Panda::Date->new("2001-01-31");
Panda::Date->month_border_adjust(1);
ok(Panda::Date->month_border_adjust);
$date->month($date->month+1);
ok($date eq "2001-02-28");
ok($date->yday == 59);
ok($date->ewday == 3);

done_testing();
