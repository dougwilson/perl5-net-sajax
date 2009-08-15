#!perl -T

use strict;
use warnings 'all';

use Test::More tests => 20;
use Test::Exception 0.03;
use Test::MockObject;

use HTTP::Response;
use URI;
use URI::QueryParam;

###########################################################################
# CREATE A MOCK USER AGENT
my $fake_ua = Test::MockObject->new;

# Mock the get request
$fake_ua->mock(get => sub {
	my ($self, $url) = @_;

	my $response;

	# Change URL into a URI object
	$url = URI->new($url);

	# Get the called function name
	my $function  = $url->query_param('rs');
	my @arguments = $url->query_param('rsargs[]');

	if ($function eq 'GetNumber') {
		my $number = int(rand(100));

		if (@arguments) {
			$number = $arguments[0];
		}

		$response = HTTP::Response->new(200, 'OK', undef, "+:$number");
	}
	elsif ($function eq 'Echo') {
		my $body = '+:var res="Error: Nothing supplied to echo"; res;';

		if (@arguments) {
			$body = $arguments[0];
		}

		$response = HTTP::Response->new(200, 'OK', undef, $body);
	}
	elsif ($function eq 'EchoUrl') {
		$response = HTTP::Response->new(200, 'OK', undef, "+:var url = '$url'; url;");
	}
	elsif ($function eq 'Malformated') {
		$response = HTTP::Response->new(200, 'OK', undef, 'I am some randome text!!');
	}
	else {
		$response = HTTP::Response->new(200, 'OK', undef, "-:$function not callable");
	}

	return $response;
});

# Say the fake user agent is a LWP::UserAgent
$fake_ua->set_isa('LWP::UserAgent');

# Set the LWP::UserAgent version
#$LWP::UserAgent::VERSION = '5.819';

use Net::SAJAX;

###########################################################################
# CONSTRUCT SAJAX OBJECT
my $sajax = new_ok('Net::SAJAX' => [
	url => 'http://example.net/app.php',
	user_agent => $fake_ua,
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

	# Function returning mal-formatted SAJAX
	dies_ok(sub {$sajax->call(function => 'Malformed')}, 'Call a malformated function');

	# Function returning mal-formatted javascript
	dies_ok(sub {$sajax->call(
		function  => 'Echo',
		arguments => [':::::Some STUFF'],
	)}, 'Call a malformated javascript');

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
