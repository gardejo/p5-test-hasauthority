#!/usr/bin/perl

use Test::More tests => 4 + 3;

use File::Spec;
my $null = File::Spec->devnull;

ok(chdir "t/eg/", "cd t/eg");
my @tap = `$^X -Mblib ../../t/97_has_version.t 2>$null`;
ok(scalar @tap, 't/97_has_version.t run ok');
ok(chdir "../..", "cd ../..");

my @expected = (
  'A.pm' => 'ok',
  'lib/B.pm' => 'ok',
  'lib/B/C.pm' => 'not ok',
);

like(shift @tap, qr/^1\.\.3/, 'good plan');

for (@tap) {
  next if /^#/;
  my $f = shift @expected;
  my $ans = shift @expected;
  like($_, qr/^$ans \d+ - $f/, $ans eq 'ok' ? "$f has version" : "$f has no version");

}