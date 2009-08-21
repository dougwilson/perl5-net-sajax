#!perl -T

use lib 't/lib';
use strict;
use warnings 'all';

use Test::More tests => 9;
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
# BAD ARGUMENTS TO CALL METHOD
{
	throws_ok
		{ $sajax->call() }
		'Net::SAJAX::Exception::MethodArguments',
		'No arguments causes an exception';

	throws_ok
		{ $sajax->call(function => 'Something', method => 'Something') }
		'Net::SAJAX::Exception::MethodArguments',
		'Unknown method causes an exception';

	throws_ok
		{ $sajax->call(function => 'Something', arguments => 'Something') }
		'Net::SAJAX::Exception::MethodArguments',
		'Arguments not an ARRAYREF causes an exception';

	throws_ok
		{ $sajax->call(function => 'Something', arguments => [1,[2]]) }
		'Net::SAJAX::Exception::MethodArguments',
		'Arguments containing a reference causes an exception';
}

###########################################################################
# BAD SERVER RESPONSE
{
	throws_ok
		{ $sajax->call(function => 'EchoStatus', arguments => [500]) }
		'Net::SAJAX::Exception::Response',
		'Bad server response causes an exception';

	throws_ok
		{ $sajax->call(function => 'Echo', arguments => ['']) }
		'Net::SAJAX::Exception::Response',
		'Unparseable response causes an exception';
}

###########################################################################
# SERVER ERROR RESPONSE
{
	throws_ok
		{ $sajax->call(function => 'IDoNotExist') }
		'Net::SAJAX::Exception::RemoteError',
		'Error message from server causes an exception';
}

###########################################################################
# SERVER ERROR RESPONSE
{
	throws_ok
		{ $sajax->call(function => 'Echo', arguments => ['ia@#saf sdafuwbgf']) }
		'Net::SAJAX::Exception::JavaScriptEvaluation',
		'Invalid JavaScript causes an exception';
}
