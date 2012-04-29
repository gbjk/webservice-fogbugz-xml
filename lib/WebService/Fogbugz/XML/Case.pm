package WebService::Fogbugz::XML::Case;

use Moose;
use v5.12;

with 'WebService::Fogbugz::XML::GetUrl';

has 'number' => (
    is        => 'rw',
    isa       => 'Int',
    required  => 1,
    );
has 'url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    );
has 'title' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'token' => (
    is  => 'rw',
    isa => 'Str',
    );
has 'tags' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'type' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'status' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'total_time' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'orig_est' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'curr_est' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'rt' => (
    is        => 'rw',
    isa       => 'Str',
    );
has 'bz' => (
    is        => 'rw',
    isa       => 'Str',
    );

sub BUILD {
    my $self = shift;

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
    }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
