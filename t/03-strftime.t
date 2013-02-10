use 5.012;
use warnings;
use Test::More;
use POSIX qw(setlocale LC_ALL); setlocale(LC_ALL, 'en_US.UTF-8'); $ENV{TZ} = 'Europe/Moscow'; POSIX::tzset();
use Panda::Date;

my $date = Panda::Date->new("2013-03-05 2:4:6");
ok(!eval{$date->strftime; 1;});
ok(!$date->strftime(""));
ok($date->strftime('%Y') eq '2013');
ok($date->strftime('%Y/%m/%d') eq '2013/03/05');
ok($date->strftime('%H-%M-%S') eq '02-04-06');
ok($date->strftime('%b %B') eq 'Mar March');
ok($date->monname eq 'March' and $date->monthname eq $date->monname);
ok($date->wdayname eq 'Tuesday' and $date->wdayname eq $date->day_of_weekname);

done_testing();
