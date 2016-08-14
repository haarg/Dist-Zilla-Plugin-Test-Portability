use strict;
use warnings;

package Dist::Zilla::Plugin::Test::Portability;
# ABSTRACT: Author tests for portability

our $VERSION = '2.001000';

use Moose;
with qw/
    Dist::Zilla::Role::FileGatherer
    Dist::Zilla::Role::FileInjector
    Dist::Zilla::Role::PrereqSource
    Dist::Zilla::Role::TextTemplate
/;
use Dist::Zilla::File::InMemory;
use Data::Section -setup;

=begin :prelude

=for test_synopsis BEGIN { die "SKIP: synopsis isn't perl code" }

=end :prelude

=head1 SYNOPSIS

In C<dist.ini>:

    [Test::Portability]
    ; you can optionally specify test options
    options = test_dos_length = 1, use_file_find = 0

=cut

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing the
following file:

  xt/author/portability.t - a standard Test::Portability::Files test

You can set options for the tests in the 'options' attribute:
Specify C<< name = value >> separated by commas.

See L<Test::Portability::Files/options> for possible options.

=cut

has options => (
  is      => 'ro',
  isa     => 'Str',
  default => '',
);

=for Pod::Coverage register_prereqs

=cut

sub register_prereqs {
    my ($self) = @_;

    $self->zilla->register_prereqs({
            type  => 'requires',
            phase => 'develop',
        },
        'Test::Portability::Files' => '0',
    );

    return;
}

=head2 munge_file

Inserts the given options into the generated test file.

=for Pod::Coverage gather_files

=cut

sub gather_files {
    my $self = shift;

    # 'name => val, name=val'
    my %options = split(/\W+/, $self->options);

    my $opts = '';
    if (%options) {
        $opts = join ', ', map { "$_ => $options{$_}" } sort keys %options;
        $opts = "options($opts);";
    }

    my $filename = 'xt/author/portability.t';
    my $content  = $self->section_data($filename);
    my $filled_content = $self->fill_in_string( $$content, { opts => $opts } );
    $self->add_file(
        Dist::Zilla::File::InMemory->new({
            name => $filename,
            content => $filled_content,
        })
    );

    return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__DATA__
___[ xt/author/portability.t ]___
#!perl

use strict;
use warnings;

use Test::More;

eval 'use Test::Portability::Files';
plan skip_all => 'Test::Portability::Files required for testing portability'
    if $@;
{{$opts}}
run_tests();
