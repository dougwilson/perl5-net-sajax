#!perl -T

use strict;
use warnings 'all';

use Test::More tests => 10;
use Test::Exception 0.03;

use Net::SAJAX;
use URI;

###########################################################################
# CONSTRUCTOR WITH URL STRING
# Expect: Success
{
	my $url = 'http://example.net/sajax_app.php';

	my $sajax = new_ok('Net::SAJAX' => [
		url => $url,
	]);

	is($sajax->url, $url, 'URL successfully accessed');

	isnt($sajax->send_rand_key, 1, 'Default is to not send rand key');
	isnt($sajax->has_target_id, 1, 'Default has no target ID');

	# Manipulate URL
	lives_ok(sub {$sajax->url('http://example.net/app.cgi')}, 'Change URL');
	is($sajax->url, 'http://example.net/app.cgi', 'URL has been modified');

	# Manipulate send rand key
	lives_ok(sub {$sajax->send_rand_key(1)}, 'Change send rand key');
	is($sajax->send_rand_key, 1, 'Send rand key has been modified');

	# Manipulate target ID
	lives_ok(sub {$sajax->target_id('some_target')}, 'Change target ID');
	is($sajax->target_id, 'some_target', 'Target ID has been modified');
}
