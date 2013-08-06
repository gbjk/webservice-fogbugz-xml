package WebService::FogBugz::XML;

use Moose;
use v5.10;

use Config::Any;
use HTTP::Request;
use IO::Prompt;
use LWP::UserAgent;
use WebService::FogBugz::XML::Case;
use XML::LibXML;

use namespace::autoclean;

has config_filename => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { (glob "~/.fb.conf")[0] } #Glob returns iterator if called in scalar context
    );
has token_filename => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { (glob "~/.fb_auth_token")[0] }
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
    lazy_build  => 1,
    );
has password => (
    is       => 'ro',
    isa      => 'Str',
    lazy_build  => 1,
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

    # Glob returns iterator unless called in scalar context
    if (-r $self->token_filename) {
        open (my $file, '<', $self->token_filename);
        chomp(my $token = <$file>);
        return $token;
        }

    my $token = $self->logon;

    return $token;
    }
sub _build_email {
    return "".prompt "Fogbugz Email address: ", '-t';
    }

sub _build_password {
    return "".prompt "Fogbugz Password: ", -te => '*';
    }

sub logon {
    my ($self) = @_;

    my $dom = $self->get_url(logon => {
        email       => $self->email,
        password    => $self->password,
        });

    my $token = $dom->findvalue('//token');

    return $token;
    }

sub logout {
    my $self = shift;

    my $dom = $self->get_url(logoff => { });
    return 1;
    }

sub get_case {
    my ($self, $number) = @_;

    my $case = WebService::FogBugz::XML::Case->new({
        service => $self,
        number  => $number,
        });

    $case->get;

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