use strict;
use Config;
use Panda::Install;

my $ivbits = $Config{ivsize}*8;

write_makefile(
    NAME      => 'Panda::Date',
    PREREQ_PM => {'Panda::Export' => 0},
    SRC       => 'src',
    INC       => '-Isrc',
    TYPEMAPS  => ['typemap', "typemap$ivbits"],
    PAYLOAD   => {'zoneinfo' => ''},
    BIN_DEPS  => 'Panda::Lib',
    BIN_SHARE => {
        INCLUDE  => {'src' => '/'},
        TYPEMAPS => {
            'typemap'        => '',
            "typemap$ivbits" => '',
        },
    },
    #DEFINE    => '-DTEST_FULL -DTEST_INLINE',
    #OPTIMIZE => '-g',
);
