use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date;

my $date = Panda::Date->new("2013-03-05 2:4:6");
ok($date.'' eq "2013-03-05 02:04:06" and $date->to_string eq $date.'' and $date.'' eq $date->sql);
ok(!defined Panda::Date->string_format);
Panda::Date->string_format("%Y%m%d%H%M%S");
ok(Panda::Date->string_format eq "%Y%m%d%H%M%S");
ok($date.'' eq "20130305020406");
Panda::Date->string_format("%Y/%m/%d");
ok($date.'' eq "2013/03/05");
Panda::Date->string_format(undef);
ok($date.'' eq "2013-03-05 02:04:06");

done_testing();
