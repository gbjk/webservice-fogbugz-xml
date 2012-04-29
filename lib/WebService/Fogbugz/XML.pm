package WebService::Fogbugz::XML;

use Moose;
use v5.12;

with 'WebService::Fogbugz::XML::GetUrl';

has 'url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    );
has 'email' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    );
has 'password' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    );
has 'token' => (
    is  => 'rw',
    isa => 'Str',
    );

sub BUILD {
    my $self = shift;

    my $dom = $self->get_url(logon => {
        email       => $self->email,
        password    => $self->password,
        });

    $self->token($dom->findvalue('//token'));
    }

sub DEMOLISH {
    my $self = shift;
    $self->logout;
    }

sub logout {
    my $self = shift;

    my $dom = $self->get_url(logoff => { });
    return 1;
    }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
