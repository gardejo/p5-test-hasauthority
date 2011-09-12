
package Test::HasAuthority;

use strict;
use warnings;

our $VERSION = '0.00';
our $AUTHORITY = 'cpan:MORIYA';

=head1 NAME

Test::HasAuthority - Check Perl modules have authority strings

=head1 SYNOPSIS

C<Test::HasAuthority> lets you check a Perl module has an authority 
string in a C<Test::Simple> fashion.

  use Test::HasAuthority tests => 1;
  pm_authority_ok("M.pm", "Valid authority");

Module authors can include the following in a F<t/has_authority.t> 
file and let C<Test::HasAuthority> find and check all 
installable PM files in a distribution.

  use Test::More;
  eval "use Test::HasAuthority";
  plan skip_all => 
       'Test::HasAuthority required for testing for authority strings' if $@;
  all_pm_authority_ok();

=head1 DESCRIPTION

Do you wanna check that every one of your Perl modules in
a distribution has an authority string? You wanna make sure
you don't forget the brand new modules you just added?
Well, that's the module you have been looking for.
Use it!

Do you wanna check someone else's distribution
to make sure the author have not commited the sin of
leaving Perl modules without an authority that can be used
to tell if you have this or that feature? C<Test::HasAuthority>
is also for you, nasty little fellow.

There's a script F<test_authority> which is installed with
this distribution. You may invoke it from within the
root directory of a distribution you just unpacked,
and it will check every F<.pm> file in the directory 
and under F<lib/> (if any).

  $ test_authority

You may also provide directories and files as arguments.

  $ test_authority *.pm lib/ inc/
  $ test_authority . 

(Be warned that many Perl modules in a F<t/> directory
do not receive authorities because they are not used 
outside the distribution.)

Ok. That's not a very useful module by now.
But it will be. Wait for the upcoming releases.

=head2 FUNCTIONS

=over 4

=cut

# most of the following code was borrowed from Test::Pod

use Test::Builder;
use ExtUtils::MakeMaker; # to lay down my hands on MM->parse_authority

my $Test = Test::Builder->new;

our @EXPORTS = qw( pm_authority_ok all_pm_authority_ok all_pm_files );

sub import {
    my $self = shift;
    my $caller = caller;

    for my $func ( @EXPORTS ) {
        no strict 'refs';
        *{$caller."::".$func} = \&$func;
    }

    $Test->exported_to($caller);
    $Test->plan(@_);
}

# from Module::Which

#=begin private

=item PRIVATE B<_pm_authority>

  $a = _pm_authority($pm);

Parses a PM file and return what it thinks is $AUTHORITY
in this file. (Actually implemented with 
C<< use ExtUtils::MakeMaker; MM->parse_authority($file) >>.)
C<$pm> is the filename (eg., F<lib/Data/Dumper.pm>).

=cut

#=end private

sub _pm_authority {
    my $pm = shift;
    my $a;
    eval { $a = MM->parse_authority($pm); };
    return $@ ? undef : $a;
}

=item B<pm_authority_ok>

  pm_authority_ok('Module.pm');
  pm_authority_ok('M.pm', 'Has valid authority');

Checks to see if the given file has a valid 
authority. Actually a valid authority string is
defined and not equal to C<'undef'> (the string)
which is return by C<_pm_authority> if an authority
cannot be determined.

=cut

sub pm_authority_ok {
  my $file = shift;
  my $name = @_ ? shift : "$file has authority";

  if (!-f $file) {
    $Test->ok(0, $name);
    $Test->diag("$file does not exist");
    return;
  }

  my $a = _pm_authority($file);
  my $ok = _is_valid_authority($a);
  $Test->ok($ok, $name);
  #$Test->diag("$file $a ") if $ok && $noisy;
}

sub _is_valid_authority {
  defined $_[0] && $_[0] ne 'undef';
}

=item B<all_pm_authority_ok>

  all_pm_authority_ok();
  all_pm_authority_ok(@PM_FILES);

Checks every given file and F<.pm> files found
under given directories to see if they provide
valid authority strings. If no argument is given,
it defaults to check every file F<*.pm> in
the current directory and recurses under the
F<lib/> directory (if it exists).

If no test plan was setted, C<Test::HasAuthority> will set one
after computing the number of files to be tested. Otherwise,
the plan is left untouched.

=cut

sub all_pm_authority_ok {
  my @pm_files = all_pm_files(@_);
  $Test->plan(tests => scalar @pm_files) unless $Test->has_plan;
  for (@pm_files) {
    pm_authority_ok($_);
  }
}

#=begin private

=item PRIVATE B<_list_pm_files>

  @pm_files = _list_pm_files(@dirs);

Returns all PM files under the given directories.

=cut

#=end private

# from Module::Which::List -   eglob("**/*.pm")

use File::Find qw(find);

sub _list_pm_files {
  my @INC = @_;
  my @files;

  my $wanted = sub {
    push @files, $_ if /\.pm$/;
  };

  for (@INC) {
    my $base = $_;
    if (-d $base) {
      find({ wanted => $wanted, no_chdir => 1 }, $base);
    }
  }
  return sort @files;
}

=item B<all_pm_files>

  @files = all_pm_files()
  @files = all_pm_files(@files_and_dirs);

Implements finding the Perl modules according to the
semantics of the previous function C<all_pm_authority_ok>.

=cut

sub all_pm_files {
  my @args;
  if (@_) {
    @args = @_;
  } else {
    @args = ( grep(-f, glob("*.pm")), "lib/" );
  }
  my @pm_files;
  for (@args) {
    if (-f) {
      push @pm_files, $_;
    } elsif (-d) {
      push @pm_files, _list_pm_files($_);
    } else {
      # not a file or directory: ignore silently 
    }
  }
  return @pm_files;

}

=back

=head1 USAGE

Other usage patterns besides the ones given in the synopsis.

  use Test::More tests => $num_tests;
  use Test::HasAuthority;
  pm_authority_ok($file1);
  pm_authority_ok($file2);

Obviously, you can't plan twice.

  use Test::More;
  use Test::HasAuthority;
  plan tests => $num_tests;
  pm_authority_ok($file);

C<plan> comes from C<Test::More>.

  use Test::More;
  use Test::HasAuthority;
  plan 'no_plan';
  pm_authority_ok($file);

C<no_plan> is ok either.

=head1 SEE ALSO

  Test::Version
  Test::HasVersion

Please reports bugs via CPAN RT, 
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-HasAuthority

=head1 ACKNOWLEDGEMENTS

=over 4

=item *

B<A. R. Ferreira> wrote L<Test::HasVersion>, which this module refer to.

=back

=head1 AUTHOR

=over 4

=item MORIYA Masaki, alias Gardejo

C<< <moriya at cpan dot org> >>,
L<http://gardejo.org/>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011 MORIYA Masaki, alias Gardejo

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
See L<perlgpl> and L<perlartistic>.

The full text of the license can be found in the F<LICENSE> file included with
this distribution.

=cut

1;

