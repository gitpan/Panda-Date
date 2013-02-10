use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date;

Panda::Date->string_format("%Y-%m-%d");

ok(!Panda::Date->range_check);
ok(Panda::Date->new("2001-02-31") eq "2001-03-03");

Panda::Date->range_check(1);
ok(Panda::Date->range_check);
my $date = Panda::Date->new("2001-02-31");
ok(!$date);
ok(!defined $date->string);
ok($date->error == E_RANGE);
ok($date->errstr);

done_testing();
