use v5.12;

use lib './lib';
use Test::More qw/no_plan/;
use WebService::Fogbugz::XML;

# Get login token
my $token;
my $token_file = $ENV{HOME}.'/.fb_auth_token';
if (-r $token_file) {
    open (my $file, '<', $token_file);
    chomp ($token = <$file>);
    close $file;
    }
else {
    die "No token!";
    }

# Get URL from config file
my $url;
if (-r 'fb.config') {
    use Config::General;
    my $conf = new Config::General('fb.config');
    my %conf = $conf ? $conf->getall : qw//;
    $url = $conf{url};
    }

# Get our FB object
my $fb = WebService::Fogbugz::XML->new({
    token   => $token,
    url     => $url,
    });

# Lots of groundwork done! This probably needs a lot of abstracting...
# Now let's get the actual testing done...
my $case = $fb->get_case(7295);
ok($case, 'Got valid case');
is($case->title => 'Test case, leave it alone', "Correct title");
is($case->tags  => 'strategic', "Correct tags");
is($case->rt    => 123456, "Correct RT");
is($case->orig_est => '1', 'Correct original estimate');
