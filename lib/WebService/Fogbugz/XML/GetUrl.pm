package WebService::Fogbugz::XML::GetUrl;

use v5.10;
use Moose::Role;

use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request;
use XML::LibXML;
use URI;

sub get_url {
    my ($self, $cmd, $args) = @_;

    my $ua = LWP::UserAgent->new();

    my $url = $self->url;

    $args->{token} = $self->token if $self->token;

    my $get_url = "$url?cmd=$cmd&".join "&", map {$_."=".$args->{$_}} keys %$args;

    my $req = HTTP::Request->new(GET => $get_url);

    my $resp = $ua->request($req);

    unless ($resp->is_success){
        say STDERR "Error talking to Fogbugz\n".$resp->_content;
        }

    my $dom = XML::LibXML->load_xml(string => $resp->content);

    return $dom->documentElement;;
    }

1;
