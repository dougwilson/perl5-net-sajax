#!perl -T

use lib 't/lib';
use strict;
use warnings 'all';

use Test::More tests => 6;
use Test::Exception 0.03;
use Test::Net::SAJAX::UserAgent;

use Net::SAJAX;

###########################################################################
# CONSTRUCT SAJAX OBJECT
my $sajax = new_ok('Net::SAJAX' => [
	url        => 'http://example.net/app.php',
	user_agent => Test::Net::SAJAX::UserAgent->new,
], 'Object creation');

###########################################################################
# REQUEST RETURNING HTML
{
	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => ['I am some text!'],
	)}, 'Returned plain text');

	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => ['<html><body>HTML Body</body></html>'],
	)}, 'Return HTML');

	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => ['<script>var res="test";</script>res;'],
	)}, 'Return HTML');

	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => ['+:<script>var res="test";</script>res;'],
	)}, 'Return HTML');

	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => ["<html><head>\n\n+:var res='test'; res;"],
	)}, 'HTML returned before SAJAX');
}
