use v5.10;

use lib './lib';
use Test::More tests => 3;
use WebService::FogBugz::XML;

# Get our FB object
my $fb = WebService::FogBugz::XML->new();

# Lots of groundwork done! This probably needs a lot of abstracting...
# Now let's get the actual testing done...
my $case = $fb->get_case(1);
ok($case, 'Got valid case');
isa_ok($case, 'WebService::FogBugz::XML::Case');
ok($case->title => "Got a title: ".$case->title);
