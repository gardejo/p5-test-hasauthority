
use Test::More;
eval "use Test::HasAuthority";
plan skip_all => 'Test::HasAuthority required for testing for authority strings' if $@;
all_pm_authority_ok();
