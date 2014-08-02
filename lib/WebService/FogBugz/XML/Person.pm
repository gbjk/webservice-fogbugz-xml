package WebService::FogBugz::XML::Person;

use Moose;
use v5.10;

use namespace::autoclean;
use Data::Dumper;

has id        => (is => 'rw', isa => 'Int');
has email     => (is => 'rw', isa => 'Str');
has full_name => (is => 'rw', isa => 'Str');

sub new_from_dom {
    my ($class, $dom) = @_;

    my $self = $class->new(
        id        => $dom->findvalue('ixPerson'),
        email     => $dom->findvalue('sEmail'),
        full_name => $dom->findvalue('sFullName'),
        );

    return $self;
    }

__PACKAGE__->meta->make_immutable;

=head1 NAME

WebService::FogBugz::XML::Person

=head1 ATTRIBUTES

=head1 TODO

=head1 AUTHORS, COPYRIGHT & LICENSE

See L<WebService::FogBugz::XML>.

=cut
