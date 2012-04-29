use v5.12;

use lib './lib';
use Test::More qw/no_plan/;
use WebService::Fogbugz::XML;
use Term::ReadKey;

my ($url, $email, $password);
# Get login details
if (-r 'fb.config') {
    use Config::General;
    my $conf = new Config::General('fb.config');
    my %conf = $conf ? $conf->getall : qw//;
    ($url, $email, $password) = ($conf{url}, $conf{email}, $conf{password});
    }
else {
    exit "Must supply config file 'fb.config'\n";
    }

unless ($url) {
    say "Please supply Fogbugz URL:";
    $url = ReadLine(0);
    }
unless ($email) {
    say "Please supply your email:";
    $email = ReadLine(0);
    }
unless ($password) {
    say "Please supply your password:";
    ReadMode('noecho');
    $password = ReadLine(0);
    ReadMode('normal');
    }

# See if they work!
my $fb = WebService::Fogbugz::XML->new({
    url      => $url,
    email    => $email,
    password => $password,
    });

ok($fb, 'Got FB object');
ok($fb->token, 'Returns valid token '.$fb->token);
ok($fb->logout, 'Successfully logged out');
