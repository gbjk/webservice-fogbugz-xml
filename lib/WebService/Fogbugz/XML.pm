package WebService::Fogbugz::XML;

use Moose;
use v5.10;

use Config::Any;
use HTTP::Request;
use LWP::UserAgent;
use WebService::Fogbugz::XML::Case;
use XML::LibXML;
use namespace::autoclean;


has config_filename => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { glob("~/.fb.conf") }
    );

has config => (
    isa         => 'HashRef',
    traits      => ['Hash'],
    lazy_build  => 1,
    handles     => {
        config  => 'accessor',
        },
    );
has url => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    default  => sub { shift->config('url') },
    );
has email => (
    is       => 'ro',
    isa      => 'Str',
    default  => '',
    );
has password => (
    is       => 'ro',
    isa      => 'Str',
    default  => '',
    );
has token => (
    is          => 'rw',
    isa         => 'Str',
    lazy_build  => 1,
    );

sub _build_config {
    my ($self) = @_;

    my $cfg = Config::Any->load_files({
        files   => [$self->config_filename],
        use_ext => 1,
        });

    my %config = map {
        my ($file, $file_config) = %$_;
        %$file_config;
        } @$cfg;

    return \%config;
    }

sub _build_token {
    my ($self) = @_;

    my $token_file = glob("~/.fb_auth_token");
    if (-r $token_file) {
        open (my $file, '<', $token_file);
        chomp(my $token = <$file>);
        return $token;
        }

    # TODO: Otherwise, ask the user for password
    die "TODO: I don't know how to ask you for your password";

    return;
    }

sub logon {
    my ($self) = @_;

    my $dom = $self->get_url(logon => {
        email       => $self->email,
        password    => $self->password,
        });

    $self->token($dom->findvalue('//token'));
    }

sub logout {
    my $self = shift;

    my $dom = $self->get_url(logoff => { });
    return 1;
    }

sub get_case {
    my ($self, $number) = @_;

    my $case = WebService::Fogbugz::XML::Case->new({
        service => $self,
        number  => $number,
        });

    return $case;
    }

sub get_url {
    my ($self, $cmd, $args) = @_;

    my $ua = LWP::UserAgent->new();

    my $url = $self->url;

    unless ($cmd eq 'logon'){
        $args->{token} = $self->token;
        }

    my $get_url = "$url?cmd=$cmd&".join "&", map {$_."=".$args->{$_}} keys %$args;

    my $req = HTTP::Request->new(GET => $get_url);

    my $resp = $ua->request($req);

    unless ($resp->is_success){
        say STDERR "Error talking to Fogbugz\n".$resp->_content;
        }

    my $dom = XML::LibXML->load_xml(string => $resp->content);

    return $dom->documentElement;
    }

__PACKAGE__->meta->make_immutable;

1;
