#!perl -T

use lib 't/lib';
use strict;
use warnings 'all';

use Test::More tests => 4;
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
# REQUEST WITH HTML AT TOP
{
	# Disable autocleaning
	$sajax->autoclean_garbage(0);

	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => ["<html><head>\n\n+:var res='test'; res;"],
	)}, 'HTML at beginning caused failure');

	# Enable autocleaning
	$sajax->autoclean_garbage(1);

	lives_and(sub {is($sajax->call(
		function  => 'Echo',
		arguments => ["<html><head>\n\n+:var res='test'; res;"],
	), 'test')}, 'Cleaned HTML at beginning');
}

###########################################################################
# REQUEST WITH LOTS OF PHP GARBAGE
{
	# Enable autocleaning
	$sajax->autoclean_garbage(1);

	lives_and(sub {is($sajax->call(
		function  => 'Echo',
		arguments => ["<html><head>\n\n<body>+:var res='test'; res;</body></html>"],
	), 'test')}, 'Lots of garbage with PHP response');
}
