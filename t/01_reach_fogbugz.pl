use v5.12;

use lib './lib';
use Test::More qw/no_plan/;
use WebService::Fogbugz::XML;
use Term::ReadKey;

# Get login details
say "Please supply Fogbugz URL:";
my $url = ReadLine(0);
say "Please supply your username:";
my $user = ReadLine(0);
say "Please supply your password:";
ReadMode('noecho');
my $password = ReadLine(0);
ReadMode('normal');

die "Must supply login credentials\n" unless ($url && $user && $password);

# See if they work!
my $fb = WebService::Fogbugz::XML->new({
    url      => $url,
    user     => $user,
    password => $password,
    });

ok($fb, 'Got FB object');
ok($fb->token, 'Returns valid token');
ok($fb->logout, 'Successfully logged out');
