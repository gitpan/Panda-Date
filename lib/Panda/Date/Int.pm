package Panda::Date::Int;
use 5.012;

=head1 NAME

Panda::Date::Int - Interval date object.

=cut

use overload '""'     => \&to_string,
             'bool'   => \&to_bool,
             '0+'     => \&to_number,
             '<=>'    => \&compare, # based on duration
             'eq'     => \&equals,  # absolute matching (from == from and till == till)
             '+'      => \&add,
             '+='     => \&add_me,
             '-'      => \&subtract,
             '-='     => \&subtract_me,
             'neg'    => \&negative,
             fallback => 1;

sub to_string { $_[0]->from.' - '.$_[0]->till }
*string = *as_string = *string = *to_string;

=head1 DESCRIPTION

Interval date is a length of time bound to particular point in time. Interval date consists of start date and end date.

=head1 CLASS METHODS

=head4 new($date | $epoch | \@ymdhms | \%ymdhms | $sql_fmt, $date | $epoch | \@ymdhms | \%ymdhms | $sql_fmt)

Creates interval object from 2 dates. Input data can be anything that date() constructor supports.

=head1 OBJECT METHODS

=head4 set_from($date | $epoch | \@ymdhms | \%ymdhms | $sql_fmt, $date | $epoch | \@ymdhms | \%ymdhms | $sql_fmt)

Set interval from data. This is much faster than creating new object.

=head4 from([$from])

Lower date, L<Panda::Date>.

=head4 till([$till])

Upper date, L<Panda::Date>.

=head4 sec(), secs, second, seconds, duration

Converts interval to accurate number of seconds between from() and till().

=head4 imin(), imins, iminute, iminutes

Converts interval to accurate integer number of minutes between from() and till(). Equals int(sec/60).

=head4 min(), mins, minute, minutes

Converts interval to accurate number of minutes between from() and till(). Equals sec/60.

=head4 ihour(), ihours

Converts interval to accurate integer number of hours between from() and till(). Equals int(sec/3600).

=head4 hour(), hours

Converts interval to accurate number of hours between from() and till(). Equals sec/3600.

=head4 iday(), idays

Converts interval to accurate integer number of days between from() and till(). Not always equals int(sec/86400).

=head4 day(), days

Converts interval to accurate number of days between from() and till(). Not always equals sec/86400.

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

Returns L<Panda::Date::Rel> that equals till() minus from(). Keep in mind that ->duration not always equal to ->relative->duration !
But from() + relative() always equals till()

=head4 '+', add($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Adds relative date to interval, i.e. adds reldate to it's lower and upper dates.
Reldate can be L<Panda::Date::Rel> object or any data valid for its constructor.

=head4 '+=', add_me($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as add(), but changes current object instead of creating new one.

=head4 '-', subtract($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Subtracts relative date from interval, i.e. subtracts reldate from its upper and lower dates.
Reldate can be L<Panda::Date::Rel> object or any data valid for its constructor.

=head4 '-=', subtract_me($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as subtract(), but changes current object instead of creating new one.

=head4 '<=>', compare($idate | [...])

Compares 2 interval dates and return -1, 0 or 1. It's based on duration().
Interval date can be number (duration), Panda::Date::Int object or arrayref with constructor data.

=head4 'eq', equals($idate | [...])

Compares 2 intervals and returns true or false. It's based on full equality (i.e. from1 eq from2 and till1 eq till2).
Interval date can be Panda::Date::Int object or arrayref with constructor data.

=head4 'neg', negative() - unary '-'

Swap from and till.

=head4 negative_me()

Same as negative(), but changes current object instead of creating new one.

=head1 OPERATOR OVERLOAD RULES

See screenshot L<http://crazypanda.ru/v/clip2net/p/F/0WuXfVRKMM.png>

=head1 AUTHOR

Pronin Oleg <syber@cpan.org>, Crazy Panda, CP Decision LTD

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;