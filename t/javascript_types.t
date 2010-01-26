#!perl -T

use lib 't/lib';
use strict;
use warnings 'all';

use Test::More tests => 14;
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
# VERFIY TYPES ARE UNWRAPPED FINE
{
	# Object
	lives_and {
		is_deeply $sajax->call(
			function  => 'Echo',
			arguments => ['+:o = {"key":"value"}'],
		), {
			key => 'value',
		};
	} 'Object';

	# Array
	lives_and {
		is_deeply $sajax->call(
			function  => 'Echo',
			arguments => ['+:a = ["a","b"]'],
		), [qw(a b)];
	} 'Array';

	# Boolean
	lives_and {
		ok $sajax->call(
			function  => 'Echo',
			arguments => ['+:b = true'],
		);
	} 'Boolean (true)';
	lives_and {
		ok !$sajax->call(
			function  => 'Echo',
			arguments => ['+:b = false'],
		);
	} 'Boolean (false)';
	lives_and {
		ok $sajax->call(
			function  => 'Echo',
			arguments => ['+:b = new Boolean(1)'],
		);
	} 'Boolean (object)';

	# Null
	lives_and {
		ok !defined $sajax->call(
			function  => 'Echo',
			arguments => ['+:n = null'],
		);
	} 'Null';

	# Number
	lives_and {
		is $sajax->call(
			function  => 'Echo',
			arguments => ['+:n = 55'],
		), 55;
	} 'Number';
	lives_and {
		is $sajax->call(
			function  => 'Echo',
			arguments => ['+:n = new Number(33)'],
		), 33;
	} 'Number (object)';

	# String
	lives_and {
		is $sajax->call(
			function  => 'Echo',
			arguments => ['+:s = "test string"'],
		), 'test string';
	} 'String';
	lives_and {
		is $sajax->call(
			function  => 'Echo',
			arguments => ['+:s = new String("string thing")'],
		), 'string thing';
	} 'String (object)';

	# Undefined
	lives_and {
		ok !defined $sajax->call(
			function  => 'Echo',
			arguments => ['+:u = undefined'],
		);
	} 'Undefined';

	# Regular expression
	lives_and {
		is_deeply $sajax->call(
			function  => 'Echo',
			arguments => ['+:r = new RegExp("test1*")'],
		), qr/test1*/;
	} 'Regular expression (object)';

	# Date
	lives_and {
		like $sajax->call(
			function  => 'Echo',
			arguments => ['+:r = new Date(2010, 10, 12, 3, 30, 14)'],
		), qr/\AFri Nov 12 03:30:14 2010/;
	} 'Date (object)';
}
