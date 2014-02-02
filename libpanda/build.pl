use 5.012;
use ExtUtils::MakeMaker;
use File::ShareDir::Install;

our $CC = 'c++';

sub write_lib_makefile {
    my %params = @_;
    sync();
    
    my $postamble = delete $params{postamble};
    $postamble = {my => $postamble} if $postamble and !ref($postamble);
    $postamble ||= {};
    
    $postamble->{mystatic} = << 'END';
$(O_FILES) : $(H_FILES)
all :: static
pure_all :: static
test:;
static :: mystatic$(LIB_EXT)
mystatic$(LIB_EXT): $(O_FILES); \
    $(AR) cr mystatic$(LIB_EXT) $(O_FILES); \
    $(RANLIB) mystatic$(LIB_EXT)
END

    $postamble->{install_share} = delete $params{INSTALL_SHARE};
    
    WriteMakefile(
        SKIP      => [qw(all static static_lib dynamic dynamic_lib test)],
        clean     => {'FILES' => 'mystatic$(LIB_EXT)'},
        CC        => $CC,
        LD        => '$(CC)',
        XSOPT     => '-C++',
        postamble => $postamble,
        %params,
    );
}

sub write_makefile {
    my %params = @_;
    sync();
    
    my $postamble = delete $params{postamble};
    $postamble = {my => $postamble} if $postamble and !ref($postamble);
    $postamble ||= {};
    $postamble->{my} //= '';

    if (my @xsi_files = glob('*.xsi') and $postamble->{my} !~ /\$\(XS_FILES\)\s+:/) {
        $postamble->{my} .= '$(XS_FILES): '.join(' ', @xsi_files)."\n\ttouch \$(XS_FILES)\n";
    }
    
    my $ext = delete $params{MYEXTLIB};
    if ($ext and @$ext) {
        my $dirs = $params{DIR} ||= [];
        my $myextlib = '';
        my @myextlib_code;
        my $extlib_h = '';
        foreach my $extlib (@$ext) {
            $myextlib .= $extlib.'/mystatic$(LIB_EXT) ';
            push @$dirs, $extlib;
            $extlib_h .= join(' ', glob($extlib.'/*.h')).' ';
            my $extlib_all = join(' ', map {glob("$extlib/$_")} '*.h', '*.cc', '*.c');
            push @myextlib_code, $extlib.'/mystatic$(LIB_EXT): '.$extlib_all.'; $(NOECHO) cd '.$extlib.' && $(MAKE) $(USEMAKEFILE) $(FIRST_MAKEFILE) all $(PASTHRU)';
        }
        $params{MYEXTLIB} = $myextlib;
        #$postamble->{build_myextlib_dep}    = '$(O_FILES) : $(MYEXTLIB) '.$extlib_h;
        $postamble->{build_myextlib_odep} = '$(O_FILES) : '.$extlib_h;
        $postamble->{build_myextlib_ldep} = 'linkext:: $(MYEXTLIB)';
        $postamble->{build_myextlib_target} = join("\n", @myextlib_code);
    }

    $params{INC} ||= '';
    $params{INC} .= ' -Ilibpanda ';

    $params{TYPEMAPS} ||= [];
    push @{$params{TYPEMAPS}}, 'libpanda/panda/perl/perlobject.map';
    
    $postamble->{install_share} = delete $params{INSTALL_SHARE};
    
    WriteMakefile(
        CC        => $CC,
        LD        => '$(CC)',
        XSOPT     => '-C++',
        OBJECT    => '$(O_FILES)',
        postamble => $postamble,
        %params,
    );
}

sub apply_install_share {
    my $params = shift;
}

sub add_section {
    my ($section, $after) = @_;
    my $arr = \@ExtUtils::MakeMaker::MM_Sections;
    my $pos = @$arr;
    if ($after) {
        for (my $i = 0; $i < @$arr; $i++) {
            next unless $arr->[$i] eq $after;
            $pos = $i+1;
            last;
        }
    }
    splice(@$arr, $pos, 0, $section);
}

sub sync {
    no strict 'refs';
    my $from = 'MYSOURCE';
    my $to = 'MY';
    foreach my $method (keys %{"${from}::"}) {
        next unless defined &{"${from}::$method"};
        *{"${to}::$method"} = \&{"${from}::$method"};
    }
}

{
    package MYSOURCE;
    sub postamble {
        my $self = shift;
        $DB::single=1;
        my %args = @_;
        
        if (my $shares = delete $args{install_share}) {
            @File::ShareDir::Install::DIRS = ();
            %File::ShareDir::Install::TYPES = ();
            $shares = [$shares] unless ref($shares) eq 'ARRAY';
            foreach my $share (@$shares) {
                if (ref($share) eq 'ARRAY') { File::ShareDir::Install::install_share(@$share) }
                else { File::ShareDir::Install::install_share($share) }
            }
            $args{install_share} = $self->File::ShareDir::Install::postamble;
        }
        
        return join("\n", values %args);
    }
}

1;
