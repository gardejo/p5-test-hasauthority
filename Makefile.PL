
use ExtUtils::MakeMaker;

my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
  NAME => 'Test::HasAuthority',
  VERSION_FROM => 'HasAuthority.pm',
  PREREQ_PM => {
    'Test::Builder'         => 0,
    'ExtUtils::MakeMaker'   => 0,
    'File::Find'            => 0,

    # required for testing
    'Test::More'            => 0,
    'Test::Builder::Tester' => 1.04,
    'File::Spec'            => 0,
  },
  EXE_FILES => [ 'bin/test_authority' ],

  ($] >= 5.005 ? (
    ABSTRACT_FROM => 'HasAuthority.pm',
    AUTHOR        => 'MORIYA Masaki, alias Gardejo <moriya at cpan dot org>'
  ) : ()),
  ($EUMM_VERSION >= 6.30_01 ? (
     LICENSE => 'perl', 
  ) : ()),

);

