package WebService::FogBugz::XML::Event;

use Moose;
use v5.10;

use namespace::autoclean;
use Data::Dumper;

has type => (is => 'rw', isa => 'Int');
has text => (is => 'rw', isa => 'Str');
has id   => (is => 'rw', isa => 'Int');
has dom  => (is => 'rw');

has _changes => (
    is => 'rw',
    isa => 'ArrayRef',
    traits => ['Array'],
    default => sub { [] },
    handles => {
        add_change => 'push',
        changes    => 'elements',
        },
    );


sub from_xml {
    my ($class, $dom) = @_;

    my $self = $class->new(
        type    => $dom->findvalue('evt'),
        text    => $dom->findvalue('s'),
        id      => $dom->getAttribute('ixBugEvent'),
        dom     => $dom,
        );

    foreach my $change_dom ($dom->getElementsByTagName('sChanges')) {
        $self->add_change( $change_dom->to_literal );
        }

    return $self;
    }

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

WebService::FogBugz::XML::Event

=head1 ATTRIBUTES

=head2 type

Type of the event.

=head2 text

Text of the event.

=head1 TODO

 Event type enumeration.

=head1 AUTHORS, COPYRIGHT & LICENSE

See L<WebService::FogBugz::XML>.

=cut
