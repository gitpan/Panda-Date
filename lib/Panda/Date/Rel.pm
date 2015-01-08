package Panda::Date::Rel;
use 5.012;
use Panda::Date;

=head1 NAME

Panda::Date::Rel - Relative date object.

=cut

use overload '""'     => \&to_string,
             'bool'   => \&to_bool,
             '0+'     => \&to_number,
             'neg'    => \&negative_new,
             '<=>'    => \&compare, # based on to_sec()
             'eq'     => \&equals,  # based on full equality only
             '+'      => \&add_new,
             '+='     => \&add,
             '-'      => \&subtract_new,
             '-='     => \&subtract,
             '*'      => \&multiply_new,
             '*='     => \&multiply,
             '/'      => \&divide_new,
             '/='     => \&divide,
             '='      => sub { $_[0] },
             fallback => 1;
             
=head1 DESCRIPTION

Relative date is a period of time not bound to any particular point in time and is used for date calculations.
Reldate consists of 6 units - seconds, minutes, hours, days, months and years. Some units convert to another inaccurate.

=head1 CLASS METHODS

=head4 new([$rel_string | $seconds | \@rel_array | \%rel_hash | $reldate])

Creates a date object using one of these source data types:

=over

=item 123456 or "123456"

Treated as a number of seconds

=item [$year, $month, $day, $hour, $min, $sec]

Missing elements are considered = 0.

=item {year => x, month => x, day => x, hour => x, min => x, sec => x}

Missing elements are considered = 0.

=item string "1Y 2M 3D 4h 5m 6s"

Any part can be absent or negative.

=item Another relative date object

Clones another object

=back

=head4 new($from, $till)

Creates relative date $rel so that $from + $rel == $till.

$from and $till can be L<Panda::Date> objects or any data supported by L<Panda::Date> constructor.

=head1 OBJECT METHODS

=head4 set($rel_string | $seconds | \@rel_array | \%rel_hash | $reldate)

=head4 set($from, $till)

Set relative date from data (data can be anything that constructor supports). This is much faster than creating new object.

=head4 year([$years]), years

Number of years in relative date

=head4 month([$months]), months, mon, mons

Number of month in relative date

=head4 day([$days]), days

Number of days in relative date

=head4 hour([$hours]), hours

Number of hours in relative date

=head4 min([$mins]), mins, minute, minutes

Number of minutes in relative date

=head4 sec([$secs]), secs, second, seconds

Number of seconds in relative date

=head4 to_sec(), to_second, to_secs, to_seconds, duration

Converts relative date to number of seconds.
If any of day/month/year are non-zero then this value can be inaccurate because one need to know exact dates
to calculate exact number of seconds.

For such calculations the following assumptions are made:

=over

=item 1M = 2_629_744s

=item 1M = 2_629_744/86400 D

=item 1D = 86400s

=back

=head4 to_min(), to_minute, to_mins, to_minutes

Converts relative date to number of minutes. If any of day/month/year are non-zero then this value can be inaccurate, see to_sec().

=head4 to_hour(), to_hours

Converts relative date to number of hours. If any of day/month/year are non-zero then this value can be inaccurate, see to_sec().

=head4 to_day(), to_days

Converts relative date to number of days. If any of sec/min/hour/month/year are non-zero then this value can be inaccurate, see to_sec().

=head4 to_month(), to_months, to_mon, to_mons

Converts relative date to number of months. If any of sec/min/hour/day are non-zero then this value can be inaccurate, see to_sec().

=head4 to_year(), to_years

Converts relative date to number of years. If any of sec/min/hour/day are non-zero then this value can be inaccurate, see to_sec().

=head4 "", to_string(), string(), as_string()

Returns string in "4M 15D 123s" format, any of YMDhms can be absent or negative. If all the parts YMDhms are 0, then "" is returned.

=head4 'bool', to_bool()

Called implicitly in boolean context.
Returns FALSE, if sec = 0 and min = 0 and .... year = 0, i.e. duration = 0. Otherwise TRUE.

=head4 '0+', to_number()

Returns to_sec().

=head4 '*', multiply_new($num)

Multiplies relative date by $num. $num can be fractional but the result is always integer.

Examples

    $rel = "1M 1D";
    print $rel * 2; # 2M 2D
    print rdate("10h")->multiply(10); # 100h

Relative date can only be multiplied by number (scalar).

No normalization are made, i.e. 12h*2 = 24h is not normalized to 1D because that would be inaccurate (on DST border day for example, 1D is 25 or 23h)

=head4 '*=', multiply($num)

Same as C<multiply_new()>, but changes current object instead of creating new one.

=head4 '/', divide_new($num)

Divides relative date by $num. $num can be fractional but the result is always integer.

System will denormalize values if in another way (rounding) precision loses are bigger,
for example "1Y" / 2 = "6M" (without denormalization it would be 0).

This applies even if units are not converted accurate. In this case assumptions mentioned in to_sec() are made.

Examples

    $rel = "2Y";
    print $rel/2; # 1Y
    print $rel/4; # 6M
    print rdate("1D")/3; # 8h
    print (rdate("1D")/3)*3; # 24h
    print MONTH/2; # "15D 5h 14m 32s"

P.S. Keep in mind that ($rel / N) * N is not always equals $rel, as well as ($rel * N) / N

=head4 '/=', divide($num)

Same as C<divide_new()>, but changes current object instead of creating new one.

=head4 '+', add_new($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Adds another rel date to current. Another reldate can be Panda::Date::Rel object or any data valid for its constructor.

Examples

    my $rel = 2*MONTH;
    print $rel+MONTH; # 3M
    print $rel+'30D'; # 2M 30D
    print $rel+[1,2,3]; # 1Y 4M 3D
    
=head4 '+=', add($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as C<add_new()>, but changes current object instead of creating new one.

Examples

    my $rel = 2*MONTH;
    $rel += '16h'; # 2M 16h
    $rel += {sec => 10, min => 20}; # 2M 16h 20m 10s
    $rel += $rel; # 4M 32h 40m 20s
    
=head4 '-', subtract_new($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Subtracts another reldate from current. Another reldate can be Panda::Date::Rel object or any data valid for its constructor.

Examples

    my $rel = 2*MONTH;
    print $rel-MONTH; # 1M
    print $rel-'30D'; # 2M -30D
    print $rel-[1,2,3]; # -1Y -3D
    
=head4 '-=', subtract($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as C<subtract_new()>, but changes current object instead of creating new one.
 
=head4 'neg', negative_new() (unary '-')

Changes sign of YMDhms

=head4 negative()

Same as C<negative_new()>, but changes current object instead of creating new one.

=head4 '<=>', compare($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Compares 2 relative dates and returns -1, 0 or 1. Another reldate can be Panda::Date::Rel object or any data valid for its constructor.

Dates are compared using C<to_sec()>, therefore 2 dates can be equal even if they consist of different components.
If you want full equality test, use 'eq'.

Examples

    MONTH > YEAR; # false
    rdate("1Y 1M") > YEAR; #true
    12*MONTH == YEAR; #true
    12*MONTH eq YEAR; #false
    
=head4 'eq', equals($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as '==' but returns TRUE only if 2 reldates are fully identical.

    $reldate = rdate("1Y 2M");
    $reldate == "1Y 2M"; # true
    $reldate == "14M";   # true
    $reldate eq "1Y 2M"; # true
    $reldate eq "14M";   # false
    
=head4 clone()

Clones object.

=head4 CLONE()

Hook for Panda::Lib::clone().

=head1 OPERATOR OVERLOAD RULES

See screenshot L<http://crazypanda.ru/v/clip2net/g/0/KfYbuNhu0b.png>

=head1 STORABLE SERIALIZATION

Storable serialization is fully supported. That means you're able to freeze Panda::Date::Rel objects and 
thaw serialized data back without losing any information.

=head1 AUTHOR

Pronin Oleg <syber@cpan.org>, Crazy Panda, CP Decision LTD

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
