use 5.012;
use inc::Module::Install;
use ExtUtils::Manifest;

name     'Panda-Date';
all_from 'lib/Panda/Date.pm';

requires 'Panda::Export';

#FIX FOR SYMLINK 'abstract'
ExtUtils::Manifest::mkmanifest();
ExtUtils::Manifest::maniadd({
    'abstract/perlobject.map' => '',
    'abstract/include/lib.h' => '',
});

makemaker_args(
    CC       => 'g++',
    LD       => '$(CC)',
    XSOPT    => '-C++',
    OBJECT   => '$(O_FILES)',
    TYPEMAPS => ['abstract/perlobject.map'],
);

{
    package MY;
    use 5.012;

    sub postamble {
        return <<'EOF';
$(OBJECT) : abstract/include/*.h *.h

$(XS_FILES) : *.xsi

EOF
    }
}

auto_install;
WriteAll;
