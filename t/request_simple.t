#!perl -T

use lib 't/lib';
use strict;
use warnings 'all';

use Test::More tests => 18;
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
# REQUEST RETURNING A NUMBER
{
	my $number;

	# GET A RANDOM NUMBER
	lives_ok(sub {$number = $sajax->call(function => 'GetNumber')}, 'Get a number');
	like($number, qr{\A \d+ \z}msx, 'Got a number');
	lives_ok(sub {$number = $sajax->call(function => 'GetNumber')}, 'Get a number');
	like($number, qr{\A \d+ \z}msx, 'Got a number');

	# ECHO BACK THE SUPPLIED NUMBER
	lives_ok(sub {$number = $sajax->call(
		function  => 'GetNumber',
		arguments => [1234]
	)}, 'Get a number');
	is($number, 1234, 'Got expected number');
}

###########################################################################
# REQUEST BAD FUNCTION
{
	my $data;

	# Non-existant function
	dies_ok(sub {$sajax->call(function => 'IDoNotExist')}, 'Call a bad function');

	# Function stripping whitespace
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ["      \n\n\n\n\t+:'I am test :)'   \n\n\n\n"],
	)}, 'Function returns lots of whitespace');
	is($data, 'I am test :)', 'Whitespace stripped as expected');
}

###########################################################################
# REQUEST COMPLEX TYPES
{
	my $data;

	# Function returning array
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ['+:var array = [1,2,3]; array;'],
	)}, 'Function returns array');
	is(ref $data, 'ARRAY', 'Recieved ARRAYREF');
	is_deeply($data, [1,2,3], 'Simple array');

	# Function returning object
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ['+:var obj = {"version": 2, "snaps": "pop"}; obj;'],
	)}, 'Function returns object');
	is(ref $data, 'HASH', 'Recieved HASHREF');
	is_deeply($data, {version => 2, snaps => 'pop'}, 'Simple object');

	# Function returning array of objects
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ['+:var arr = [{"a": 2, "b": "c"},{"d": 7, 40: "e"}]; arr;'],
	)}, 'Function returns array of objects');
	is_deeply($data, [{a => 2, b => 'c'},{d => 7, 40 => 'e'}], 'Simple array of objects');
}
