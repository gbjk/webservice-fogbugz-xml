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
    default  => '',
    );
has 'password' => (
    is       => 'ro',
    isa      => 'Str',
    default  => '',
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
    # Don't want it to keep wiping out tokens whilst I'm testing.
    # Maybe put this back later, maybe stop bothering...
    #$self->logout;
    }

sub logout {
    my $self = shift;

    my $dom = $self->get_url(logoff => { });
    return 1;
    }

sub get_case {
    my ($self, $number) = @_;

    use WebService::Fogbugz::XML::Case;
    my $case = WebService::Fogbugz::XML::Case->new({
        url     => $self->url,
        token   => $self->token,
        number  => $number,
        });
    return $case;
    }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
