package WebService::FogBugz::XML::Case;

use Moose;
use v5.10;

use namespace::autoclean;

use WebService::FogBugz::XML::Event;
use DateTime;
use DateTime::Format::Strptime;
use Data::Dumper;
use DDP;

has service => (
    isa         => 'WebService::FogBugz::XML',
    is          => 'ro',
    handles     => [qw/get_url site_url/],
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
has trello_id => (
    is        => 'rw',
    isa       => 'Str',
    );
has trello_order => (
    is        => 'rw',
    isa       => 'Str',
    );
has trello_list => (
    is        => 'rw',
    isa       => 'Str',
    );
has last_scout_occurrence => (
    is        => 'rw',
    isa       => 'Maybe[DateTime]',
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

sub url {
    my ($self) = @_;

    return $self->site_url . 'cases/' . $self->number . '/';
    }

sub get {
    my ($self, $number) = @_;

    unless (ref $self){
        $self = $self->new(number => $number);
        }

    my $case_cols = 'tags,sTitle,sStatus,sCategory,hrsOrigEst,hrsCurrEst,hrsElapsed,plugin_customfields_at_fogcreek_com_rto32,ixBugParent,events,plugin_customfields,dtLastOccurrence';

    my $dom = $self->get_url(search => {
        q       => $self->number,
        cols    => $case_cols,
        });

    $self->populate_fields($dom);
    return $self;
    }

sub find_event_by_id {
    my ($self, $id) = @_;

    my ($event) =  grep {$_->id == $id} $self->events;
    return $event;
    }

sub new_from_dom {
    my ($class, $dom) =@_;

    my $num = $dom->getAttribute('ixBug');
    my $self = $class->new(number => $num);
    $self->populate_fields($dom);
    return $self;
    }

sub populate_fields {
    my ($self, $dom) = @_;

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
    $self->trello_id($dom->findvalue('//plugin_customfields_at_fogcreek_com_trelloxidp8d'));
    $self->trello_order($dom->findvalue('//plugin_customfields_at_fogcreek_com_trelloxorderb8e'));
    $self->trello_list($dom->findvalue('//plugin_customfields_at_fogcreek_com_trelloxlistt7f'));

    if (my $last_occurrence = $dom->findvalue('//dtLastOccurrence')){
        state $date_parser = DateTime::Format::Strptime->new(pattern => "%FT%H:%M:%SZ");
        if (my $date = $date_parser->parse_datetime( $last_occurrence )){
            $self->last_scout_occurrence( $date );
            }
        else {
            warn "Couldn't parse date time $last_occurrence";
            }
        }

    foreach my $event_dom ($dom->findnodes('//events/event')){
        my $event = WebService::FogBugz::XML::Event->from_xml($event_dom);
        $self->add_event($event);
        }
    }

sub update {
    my ($self) = @_;

    my $dom = $self->get_url(edit => {
        ixBug   => $self->number,
        plugin_customfields_at_fogcreek_com_trelloxidp8d    => $self->trello_id,
        plugin_customfields_at_fogcreek_com_trelloxorderb8e => $self->trello_order,
        plugin_customfields_at_fogcreek_com_trelloxlistt7f  => $self->trello_list,
        });

    return;
    }

sub add_comment {
    my ($self, $comment) = @_;

    my $dom = $self->get_url(edit => {
        ixBug   => $self->number,
        sEvent  => $comment,
        });

    return;
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

=head1 NAME

WebService::FogBugz::XML::Case

=head1 ATTRIBUTES

=head2 service

The WebService::FogBugz::XML service used to talk to fogbugz

Default: WebService::FogBugz::XML->new()

=head2 FogBugz ATTRIBUTES

The following attributes map directly to the API attributes.

=over

=item number

=item parent

=item title

=item tags

=item type

=item status

=item total_time

=item orig_est

=item curr_est

=item events

Array of L<WebService::FogBugz::XML::Event> objects for this case

=back

=head2 Custom ATTRIBUTES

Some custom attributes currently supported. This needs abstracting to be generically supportable.

=over

=item rt

RequestTracker reference number

=item bz

Bugzilla reference number

=back

=head1 METHODS

=head2 get ($case_number)

Retrieves a case by case number.

=head2 start_work

Starts work on this case.

=head1 TODO

 stop_work

 MASSIVE caveat - update only writes trello custom fields

=head1 AUTHORS, COPYRIGHT & LICENSE

See L<WebService::FogBugz::XML>.

=cut
