use 5.012;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/lib'; use PDTest;

my $info = tzget();
ok($info);
is($info->{is_local}, 1);
is($info->{name}, tzname());
is(ref($info->{transitions}), 'ARRAY');

foreach my $zone (available_zones()) {
    my $info = tzget($zone);
    ok($info);
    is($info->{is_local}, 0);
    is($info->{name}, $zone);
    is(ref($info->{transitions}), 'ARRAY');
}

done_testing();