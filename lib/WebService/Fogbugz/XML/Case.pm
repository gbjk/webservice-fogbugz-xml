package WebService::Fogbugz::XML::Case;

use Moose;
use v5.10;

use namespace::autoclean;

has service => (
    isa         => 'WebService::Fogbugz::XML',
    is          => 'ro',
    handles     => [qw/get_url/],
    lazy        => 1,
    default     => sub { WebService::Fogbugz::XML->new },
    );

has number => (
    is        => 'rw',
    isa       => 'Int',
    required  => 1,
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

# Class method
sub get {
    my ($class, $number) = @_;

    my $self = $class->new(number => $number);

    my $case_cols = 'tags,sTitle,sStatus,sCategory,hrsOrigEst,hrsCurrEst,hrsElapsed,plugin_customfields_at_fogcreek_com_rto31,plugin_customfields_at_fogcreek_com_bugzillaa62,plugin_customfields_at_fogcreek_com_clients15';

    my $dom = $self->get_url(search => {
        q       => $self->number,
        cols    => $case_cols,
        });

    $self->tags($dom->findvalue('//tag'));
    $self->title($dom->findvalue('//sTitle'));
    $self->type($dom->findvalue('//sCategory'));
    $self->status($dom->findvalue('//sStatus'));
    $self->total_time($dom->findvalue('//hrsElapsed'));
    $self->orig_est($dom->findvalue('//hrsOrigEst'));
    $self->curr_est($dom->findvalue('//hrsCurrEst'));
    $self->rt($dom->findvalue('//plugin_customfields_at_fogcreek_com_rto31'));
    $self->bz($dom->findvalue('//plugin_customfields_at_fogcreek_com_bugzillaa62'));

    return $self;
    }

__PACKAGE__->meta->make_immutable;

1;
