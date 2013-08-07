use v5.10;

use lib './lib';
use Test::More tests => 2;
use WebService::FogBugz::XML;
use Term::ReadKey;

my $fb = WebService::FogBugz::XML->new();

# See if they work!

ok($fb, 'Got FB object');
ok($fb->token, 'Returns valid token '.$fb->token);
