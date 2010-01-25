#!perl -T

use lib 't/lib';
use strict;
use warnings 'all';

use Test::More tests => 10;
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
# ARRAY
{
	my $data;

	# Function returning array
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ['+:var array = [1,2,3]; array;'],
	)}, 'Function returns array');
	is(ref $data, 'ARRAY', 'Recieved ARRAYREF');
	is_deeply($data, [1,2,3], 'Simple array');
}

###########################################################################
# HASH
{
	my $data;

	# Function returning object
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ['+:var obj = {"version": 2, "snaps": "pop"}; obj;'],
	)}, 'Function returns object');
	is(ref $data, 'HASH', 'Recieved HASHREF');
	is_deeply($data, {version => 2, snaps => 'pop'}, 'Simple object');
}

###########################################################################
# COMBINED
{
	my $data;

	# Function returning array of objects
	lives_ok(sub {$data = $sajax->call(
		function  => 'Echo',
		arguments => ['+:var arr = [{"a": 2, "b": "c"},{"d": 7, 40: "e"}]; arr;'],
	)}, 'Function returns array of objects');
	is_deeply($data, [{a => 2, b => 'c'},{d => 7, 40 => 'e'}], 'Simple array of objects');

	# Function returning all supported types at once
	lives_and {
		is_deeply $sajax->call(
			function  => 'Echo',
			arguments => ['+:var res = {"object":{},"array":[],"boolean":true,'
				. '"null":null,"number":1,"string":"test","undefined":undefined,'
				. '"number_object":new Object(5),"regexp":new RegExp("test.+")}; res;'],
		), {
			object        => {},
			array         => [],
			boolean       => 1,
			null          => undef,
			number        => 1,
			string        => 'test',
			undefined     => undef,
			number_object => 5,
			regexp        => qr/test.+/,
		};
	} 'All types unwrapped';
}
