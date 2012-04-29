use v5.12;

use lib './lib';
use Test::More qw/no_plan/;
use WebService::Fogbugz::XML;
use Term::ReadKey;

my ($url, $user, $password);
# Get login details
if (-r 'fb.config') {
    use Config::General;
    my $conf = new Config::General('fb.config');
    my %conf = $conf ? $conf->getall : qw//;
    ($url, $user, $password) = ($conf{url}, $conf{user}, $conf{password});
    }
else {
    exit "Must supply config file 'fb.config'\n";
    }

unless ($url) {
    say "Please supply Fogbugz URL:";
    $url = ReadLine(0);
    }
unless ($user) {
    say "Please supply your username:";
    $user = ReadLine(0);
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
    user     => $user,
    password => $password,
    });

ok($fb, 'Got FB object');
ok($fb->token, 'Returns valid token');
ok($fb->logout, 'Successfully logged out');
