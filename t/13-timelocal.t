use 5.012;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/lib'; use PDTest;

foreach my $file (map {"local$_"} 1,2,3,4,5,6,7) {
    my $data = get_dates($file);
    while (my ($zone, $list) = each %$data) {
        tzset($zone);
        foreach my $row (@$list) {
            my @params = get_row_tl($row);
            my $result = &timelocal(@params);
            is($result, $row->[0], "timelocal($zone): @params");
        }
    }
}

my ($Y,$M,$D,$h,$m,$s,$isdst);

tzset('Europe/Moscow');
# check past
is(timelocal(19, 13, 14, 30, 9, 1876), -2940149821) if is64bit();
# check past within first transition.
is(timelocal(40, 59, 23, 31, 11, 1879), -2840149820) if is64bit(); # Auto-dst should always choose later time by default
is(timelocal(40, 59, 23, 31, 11, 1879, 0), -2840149820) if is64bit(); # force choosing later time
is(timelocal(59, 59, 23, 31, 11, 1879, 0), -2840149801) if is64bit(); # force choosing later time
is(timelocal(40, 59, 23, 31, 11, 1879, 1), -2840149840) if is64bit(); # force choosing earlier time
is(timelocal(59, 59, 23, 31, 11, 1879, 1), -2840149821) if is64bit(); # force choosing earlier time
is(timelocal(0, 0, 0, 1, 0, 1880), -2840149800) if is64bit(); # no ambiguity
# check that forcing earlier/later time doesn't matter when no ambiguity
is(timelocal(19, 13, 14, 30, 9, 1876, 0), -2940149821) if is64bit();
is(timelocal(19, 13, 14, 30, 9, 1876, 1), -2940149821) if is64bit();
is(timelocal(0, 0, 0, 1, 0, 1880, 0), -2840149800) if is64bit();
is(timelocal(0, 0, 0, 1, 0, 1880, 1), -2840149800) if is64bit();
# transitions
is(timelocal(0, 20, 4, 21, 10, 2004), 1101000000); # standart time
is(timelocal(20, 33, 23, 5, 5, 2005), 1118000000); # dst
# transition jump forward
is(timelocal(59, 59, 1, 27, 2, 2005), 1111877999);
is(timelocal(0, 0, 3, 27, 2, 2005), 1111878000);
# normalize impossible time (should be 3:30:00)
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2005,2,27,2,30,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 1111879800);
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [0,2005,2,27,2,30,0]);
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 1111879800);
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2005,2,27,3,30,0]);
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2005,2,27,3,0,-1);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 1111881599);
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 1111881599);
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2005,2,27,3,59,59]);
# non-standart jump forward (DST + change zone, 2hrs)
is(timelocal(59, 59, 21, 31, 4, 1918), -1627965049);
is(timelocal(0, 0, 0, 1, 5, 1918), -1627965048);
($isdst,$Y,$M,$D,$h,$m,$s) = (0,1918,4,31,22,0,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), -1627965048);
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), -1627965048);
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,1918,5,1,0,0,0]);
($isdst,$Y,$M,$D,$h,$m,$s) = (0,1918,4,31,23,30,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), -1627959648);
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), -1627959648);
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,1918,5,1,1,30,0]);
# transition jump backward
is(timelocal(59, 59, 1, 30, 9, 2005), 1130623199); # no ambiguity
is(timelocal(0, 0, 2, 30, 9, 2005), 1130626800); # ambiguity resolved as later time
is(timelocal(0, 0, 2, 30, 9, 2005, 0), 1130626800); # ambiguity resolved as later time
is(timelocal(0, 0, 2, 30, 9, 2005, -1), 1130626800); # ambiguity resolved as later time
is(timelocal(0, 0, 2, 30, 9, 2005, 1), 1130623200); # ambiguity resolved as ealier time
is(timelocal(59, 59, 2, 30, 9, 2005), 1130630399); # ambiguity resolved as later time
is(timelocal(59, 59, 2, 30, 9, 2005, 1), 1130626799); # ambiguity resolved as ealier time
is(timelocal(0, 0, 3, 30, 9, 2005), 1130630400); # no ambiguity
is(timelocal(0, 0, 3, 30, 9, 2005, 1), 1130630400); # no ambiguity
# future static rules
is(timelocal(20, 33, 7, 18, 4, 2033), 2000000000);
# normalize
($isdst,$Y,$M,$D,$h,$m,$s) = (1,2070,-123,-1234,-12345,-123456,133456789);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 2807081029) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 2807081029) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [0,2058,11,14,12,43,49]) if is64bit();

# future dynamic rules for northern hemisphere
tzset('America/New_York');
# jump forward
is(timelocal(59, 59, 1, 11, 2, 2085), 3635132399) if is64bit();
is(timelocal(59, 59, 1, 11, 2, 2085, 1), 3635132399) if is64bit();
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2085,2,11,2,0,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 3635132400) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 3635132400) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2085,2,11,3,0,0]) if is64bit();
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2085,2,11,2,30,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 3635134200) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 3635134200) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2085,2,11,3,30,0]) if is64bit();
is(timelocal(0, 0, 3, 11, 2, 2085), 3635132400) if is64bit();
is(timelocal(0, 0, 3, 11, 2, 2085, 1), 3635132400) if is64bit();
# jump backward
is(timelocal(59, 59, 0, 4, 10, 2085), 3655688399) if is64bit();
is(timelocal(59, 59, 0, 4, 10, 2085, 1), 3655688399) if is64bit();
is(timelocal(0, 0, 1, 4, 10, 2085), 3655692000) if is64bit(); # later time
is(timelocal(0, 0, 1, 4, 10, 2085, 0), 3655692000) if is64bit(); # later time
is(timelocal(0, 0, 1, 4, 10, 2085, -1), 3655692000) if is64bit(); # later time
is(timelocal(0, 0, 1, 4, 10, 2085, 1), 3655688400) if is64bit(); # earlier time
is(timelocal(59, 59, 1, 4, 10, 2085), 3655695599) if is64bit(); # later time
is(timelocal(59, 59, 1, 4, 10, 2085, 1), 3655691999) if is64bit(); # earlier time
is(timelocal(0, 0, 2, 4, 10, 2085), 3655695600) if is64bit();
is(timelocal(0, 0, 2, 4, 10, 2085, 1), 3655695600) if is64bit();
#normalize
($isdst,$Y,$M,$D,$h,$m,$s) = (1,2070,-123,-1234,-12345,-123456,133456789);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 2807113429) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 2807113429) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [0,2058,11,14,12,43,49]) if is64bit();

# future dynamic rules for southern hemisphere
tzset('Australia/Melbourne');
# jump backward
is(timelocal(59, 59, 1, 2, 3, 2051), 2563973999) if is64bit();
is(timelocal(59, 59, 1, 2, 3, 2051, 1), 2563973999) if is64bit();
is(timelocal(0, 0, 2, 2, 3, 2051), 2563977600) if is64bit(); # later time
is(timelocal(0, 0, 2, 2, 3, 2051, 0), 2563977600) if is64bit(); # later time
is(timelocal(0, 0, 2, 2, 3, 2051, -1), 2563977600) if is64bit(); # later time
is(timelocal(0, 0, 2, 2, 3, 2051, 1), 2563974000) if is64bit(); # earlier time
is(timelocal(59, 59, 2, 2, 3, 2051), 2563981199) if is64bit(); # later time
is(timelocal(59, 59, 2, 2, 3, 2051, 1), 2563977599) if is64bit(); # earlier time
is(timelocal(0, 0, 3, 2, 3, 2051), 2563981200) if is64bit();
is(timelocal(0, 0, 3, 2, 3, 2051, 1), 2563981200) if is64bit();
# jump forward
is(timelocal(59, 59, 1, 1, 9, 2051), 2579702399) if is64bit();
is(timelocal(59, 59, 1, 1, 9, 2051, 1), 2579702399) if is64bit();
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2051,9,1,2,0,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 2579702400) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 2579702400) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2051,9,1,3,0,0]) if is64bit();
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2051,9,1,2,30,0);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 2579704200) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 2579704200) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2051,9,1,3,30,0]) if is64bit();
is(timelocal(0, 0, 3, 1, 9, 2051), 2579702400) if is64bit();
is(timelocal(0, 0, 3, 1, 9, 2051, 1), 2579702400) if is64bit();
# normalize
($isdst,$Y,$M,$D,$h,$m,$s) = (0,2070,-123,-1234,-12345,-123456,133456789);
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 2807055829) if is64bit();
is(timelocaln($s,$m,$h,$D,$M,$Y,$isdst), 2807055829) if is64bit();
cmp_deeply([$isdst,$Y,$M,$D,$h,$m,$s], [1,2058,11,14,12,43,49]) if is64bit();

# check virtual zones
($Y,$M,$D,$h,$m,$s) = (2014,0,16,17,18,0);
tzset('GMT-9');
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 1389860280);
tzset('GMT9');
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 1389925080);
tzset('GMT+9');
is(timelocal($s,$m,$h,$D,$M,$Y,$isdst), 1389925080);

done_testing();