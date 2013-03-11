#!/usr/bin/perl
use 5.012;
use lib 'blib/lib', 'blib/arch';
use Benchmark qw/timethis timethese/;
use Scalar::Util qw/blessed/;
use POSIX;
#$ENV{TZ} = 'Europe/Kiev'; POSIX::tzset();
use Panda::Date qw/now today date rdate :const idate/;
use Class::Date;
use Data::Dumper qw/Dumper/;
use Storable qw/freeze nfreeze thaw dclone/;
use JSON::XS;
say "START";
use Class::Date;

Panda::Date->dst_adjust(1);

foreach my $class (qw/Panda::Date Class::Date/) {

    my $date = $class->new("2005-03-27 01:00:01");
    my $till = $class->new("2006-01-01");

    say $date;
    say ($date+3600);
}
#exit;

my $cdate = new Class::Date("2013-06-05 23:45:56");
my $date  = new Panda::Date("2013-06-05 23:45:56");
my $crel = Class::Date::Rel->new("1M");
my $rel  = rdate("1M");
my $idate = idate("2013-06-05 23:45:56", "2014-07-06 23:45:56");
1;

my @buff;

timethese(-1, {
    cdate_new_str   => sub { push @buff, new Class::Date("2013-01-25 21:26:43"); }, # push @buff to avoid calling DESTROY
    panda_new_str   => sub { push @buff, new Panda::Date("2013-01-25 21:26:43"); },
    cdate_new_epoch => sub { push @buff, new Class::Date(1000000000); },
    panda_new_epoch => sub { push @buff, new Panda::Date(1000000000); },
    panda_new_reuse => sub { state $date = new Panda::Date(0); $date->set_from(1000000000); },
    
    cdate_now => sub { Class::Date->now; },
    panda_now => sub { now(); },
    
    cdate_truncate    => sub { $cdate->truncate },
    panda_truncate_me => sub { $date->truncate_me },
    panda_truncate    => sub { $date->truncate },

    cdate_today  => sub { Class::Date->now->truncate; },
    panda_today1 => sub { now()->truncate_me; },
    panda_today2 => sub { today(); },

    cdate_stringify => sub { $cdate->string },
    panda_stringify => sub { $date->to_string },

    cdate_strftime => sub { $cdate->strftime("%H:%M:%S") },
    panda_strftime => sub { $date->strftime("%H:%M:%S") },

    cdate_clone_simple => sub { $cdate->clone },
    panda_clone_simple => sub { $date->clone },
    cdate_clone_change => sub { $cdate->clone(year => 2008, month => 12) },
    panda_clone_change => sub { $date->clone({year => 2008, month => 12}) },

    cdate_rel_new_sec => sub { new Class::Date::Rel 1000 },
    panda_rel_new_sec => sub { new Panda::Date::Rel 1000 },
    cdate_rel_new_str => sub { new Class::Date::Rel "1Y 2M 3D 4h 5m 6s" },
    panda_rel_new_str => sub { new Panda::Date::Rel "1Y 2M 3D 4h 5m 6s" },
    
    cdate_add     => sub { $cdate = $cdate + '1M' },
    panda_add     => sub { $date = $date + '1M' },
    panda_add_me  => sub { $date += '1M' },
    panda_add_me2 => sub { $date += MONTH },
    panda_add_me3 => sub { $date->month($date->month+1) },

    cdate_compare => sub { $cdate == $cdate },
    panda_compare => sub { $date == $date },
});

1;
