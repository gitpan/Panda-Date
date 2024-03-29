package Panda::Date::Int;
use 5.012;
use Panda::Date;

=head1 NAME

Panda::Date::Int - Interval date object.

=cut

use overload '""'     => \&to_string,
             'bool'   => \&to_bool,
             '0+'     => \&to_number,
             '<=>'    => \&compare, # for idates - based on duration
             'eq'     => \&equals,  # absolute matching (from == from and till == till)
             '+'      => \&add_new,
             '+='     => \&add,
             '-'      => \&subtract_new,
             '-='     => \&subtract,
             'neg'    => \&negative_new,
             fallback => 1;

=head1 DESCRIPTION

Interval date is a period of time bound to particular point in time. Interval date consists of start date and end date.

=head1 CLASS METHODS

=head4 new($date | $epoch | \@ymdhms | \%ymdhms | $iso_fmt, $date | $epoch | \@ymdhms | \%ymdhms | $iso_fmt)

Creates interval object from 2 dates. Input data can be anything that date() constructor supports.

=head4 new($stringified | \@from_till)

Creates interval object from it's stringified form (->to_string) or array with from and till dates.

=head1 OBJECT METHODS

=head4 set($date | $epoch | \@ymdhms | \%ymdhms | $iso_fmt, $date | $epoch | \@ymdhms | \%ymdhms | $iso_fmt)

Set interval from data. This is much faster than creating new object.

=head4 set($stringified | \@from_till)

Set interval from stringified form or array with from and till dates.

=head4 from([$from])

Lower date, L<Panda::Date>.

=head4 till([$till])

Upper date, L<Panda::Date>.

=head4 sec(), secs, second, seconds, duration

Converts interval to accurate number of seconds between from() and till().

=head4 imin(), imins, iminute, iminutes

Converts interval to accurate integer number of minutes between from() and till().

=head4 min(), mins, minute, minutes

Converts interval to accurate number of minutes between from() and till().

=head4 ihour(), ihours

Converts interval to accurate integer number of hours between from() and till().

=head4 hour(), hours

Converts interval to accurate number of hours between from() and till().

=head4 iday(), idays

Converts interval to accurate integer number of days between from() and till().

=head4 day(), days

Converts interval to accurate number of days between from() and till().

=head4 imonth(), imonths, imon, imons

Converts interval to accurate integer number of months between from() and till().

=head4 month(), months, mon, mons

Converts interval to accurate number of months between from() and till(). Fractional part are based on how
many days left till last day of month.

=head4 iyear(), iyears

Converts interval to accurate integer number of years between from() and till().

=head4 year(), years

Converts interval to accurate number of years between from() and till().

=head4 relative ()

Returns L<Panda::Date::Rel> that equals till() minus from(). Keep in mind that C<duration()> not always equal to relative->duration() !
But C<from() + relative()> always equals C<till()>

=head4 "", to_string(), string(), as_string()

Returns string in "<LOWER DATE> ~ <UPPER DATE>" format, for example "2012-01-01 03:04:05 ~ 2013-02-03 05:06:14".
If any of 'till' or 'from' dates have error, returns undef.

=head4 '+', add_new($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Adds relative date to interval, i.e. adds reldate to it's lower and upper dates.
Reldate can be L<Panda::Date::Rel> object or any data valid for its constructor.

=head4 '+=', add($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as C<add()>, but changes current object instead of creating new one.

=head4 '-', subtract_new($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Subtracts relative date from interval, i.e. subtracts reldate from its upper and lower dates.
Reldate can be L<Panda::Date::Rel> object or any data valid for its constructor.

=head4 '-=', subtract($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as C<subtract_new()>, but changes current object instead of creating new one.

=head4 '<=>', compare($idate | [...])

Compares 2 interval dates and return -1, 0 or 1. It's based on duration().
Interval date can be number (duration), Panda::Date::Int object or arrayref with constructor data.

=head4 'eq', equals($idate | [...])

Compares 2 intervals and returns true or false. It's based on full equality (i.e. from1 eq from2 and till1 eq till2).
Interval date can be Panda::Date::Int object or arrayref with constructor data.

=head4 'neg', negative_new() - unary '-'

Swap from and till.

=head4 negative()

Same as C<negative_new()>, but changes current object instead of creating new one.

=head4 includes($date | $epoch | \@ymdhms | \%ymdhms | $iso_fmt)

Returns -1 if date presented by argument is greater than C<till()> date.

Returns 0 if date is between C<from()> and C<till()> dates.

Returns 1 otherwise.

=head1 OPERATOR OVERLOAD RULES

See screenshot L<http://crazypanda.ru/v/clip2net/p/F/0WuXfVRKMM.png>

=head1 STORABLE SERIALIZATION

Storable serialization is fully supported. That means you're able to freeze Panda::Date::Int objects and 
thaw serialized data back without losing any information.

=head1 AUTHOR

Pronin Oleg <syber@cpan.org>, Crazy Panda, CP Decision LTD

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;