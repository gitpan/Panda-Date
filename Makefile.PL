use 5.012;
require 'libpanda/build.pl';

write_makefile(
    NAME               => 'Panda::Date',
    VERSION_FROM       => 'lib/Panda/Time.pm',
    ABSTRACT_FROM      => 'lib/Panda/Date.pm',
    PREREQ_PM          => {'Panda::Export' => 0, 'Test::Deep' => 0, 'File::ShareDir' => 0},
    BUILD_REQUIRES     => {'Test::Simple' => 0.96},
    CONFIGURE_REQUIRES => {'File::ShareDir::Install' => '0.07'},
    MYEXTLIB           => ['libpanda/panda/time', 'libpanda/panda/date'],
    INSTALL_SHARE      => 'share',
    #DEFINE             => '-DTEST_FULL -DTEST_INLINE'
    #OPTIMIZE           => '-g',
);