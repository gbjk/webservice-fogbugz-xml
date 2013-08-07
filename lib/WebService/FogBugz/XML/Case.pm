package WebService::FogBugz::XML::Case;

use Moose;
use v5.10;

use namespace::autoclean;

use WebService::FogBugz::XML::Event;
use Data::Dumper;

has service => (
    isa         => 'WebService::FogBugz::XML',
    is          => 'ro',
    handles     => [qw/get_url/],
    lazy        => 1,
    default     => sub { WebService::FogBugz::XML->new },
    );

has number => (
    is        => 'rw',
    isa       => 'Int',
    required  => 1,
    );
has parent => (
    is        => 'rw',
    isa       => 'Int|Str',
    );
has title => (
    is        => 'rw',
    isa       => 'Str',
    );
has token => (
    is  => 'rw',
    isa => 'Str',
    );
has tags => (
    is        => 'rw',
    isa       => 'Str',
    );
has type => (
    is        => 'rw',
    isa       => 'Str',
    );
has status => (
    is        => 'rw',
    isa       => 'Str',
    );
has total_time => (
    is        => 'rw',
    isa       => 'Str',
    );
has orig_est => (
    is        => 'rw',
    isa       => 'Str',
    );
has curr_est => (
    is        => 'rw',
    isa       => 'Str',
    );
has rt => (
    is        => 'rw',
    isa       => 'Str',
    );
has bz => (
    is        => 'rw',
    isa       => 'Str',
    );
has events => (
    isa       => 'ArrayRef[WebService::FogBugz::XML::Event]',
    traits    => ['Array'],
    default   => sub { [] },
    handles   => {
        add_event    => 'push',
        events       => 'elements',
        },
    );

sub get {
    my ($self, $number) = @_;

    unless (ref $self){
        $self = $self->new(number => $number);
        }

    my $case_cols = 'tags,sTitle,sStatus,sCategory,hrsOrigEst,hrsCurrEst,hrsElapsed,plugin_customfields_at_fogcreek_com_rto31,plugin_customfields_at_fogcreek_com_bugzillaa62,plugin_customfields_at_fogcreek_com_clients15,ixBugParent,events';

    my $dom = $self->get_url(search => {
        q       => $self->number,
        cols    => $case_cols,
        });

    $self->parent($dom->findvalue('//ixBugParent'));
    $self->tags($dom->findvalue('//tag'));
    $self->title($dom->findvalue('//sTitle'));
    $self->type($dom->findvalue('//sCategory'));
    $self->status($dom->findvalue('//sStatus'));
    $self->total_time($dom->findvalue('//hrsElapsed'));
    $self->orig_est($dom->findvalue('//hrsOrigEst'));
    $self->curr_est($dom->findvalue('//hrsCurrEst'));
    $self->rt($dom->findvalue('//plugin_customfields_at_fogcreek_com_rto31'));
    $self->bz($dom->findvalue('//plugin_customfields_at_fogcreek_com_bugzillaa62'));
    foreach my $event_dom ($dom->findnodes('//events/event')){
        my $event = WebService::FogBugz::XML::Event->from_xml($event_dom);
        $self->add_event($event);
        }

    return $self;
    }

sub start_work {
    my ($self) = @_;

    my $resp = $self->get_url(startWork => {
        ixBug   => $self->number,
        });

    return;
    }

__PACKAGE__->meta->make_immutable;

1;
