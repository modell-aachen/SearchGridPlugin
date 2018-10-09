#!/usr/bin/perl -w
use strict;
BEGIN { unshift @INC, split(/:/, $ENV{FOSWIKI_LIBS}); }
use Foswiki::Contrib::Build;

package SearchGridBuild;
our @ISA = qw(Foswiki::Contrib::Build);

sub new {
  my $class = shift;
  return bless($class->SUPER::new( "SearchGridPlugin" ), $class);
}

sub target_build {
  my $this = shift;
}

sub target_compress {}

my $build = SearchGridBuild->new();
$build->build($build->{target});
