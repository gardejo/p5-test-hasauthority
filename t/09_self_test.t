
use Test::More tests => 2;

BEGIN {
    use_ok( "Test::HasAuthority" );
}

my $self = $INC{'Test/HasAuthority.pm'};
pm_authority_ok($self, "My own authority is ok");
