#!perl -T

use strict;
use warnings 'all';

use Test::More tests => 7;
use Test::Exception 0.03;
use Test::MockObject;

use HTTP::Response;
use URI;
use URI::QueryParam;

###########################################################################
# CREATE A MOCK USER AGENT
my $fake_ua = Test::MockObject->new;

my $process_request = sub {
	my ($function, $arguments, $url) = @_;

	my $response;

	# Change URL into a URI object
	$url = URI->new($url);

	if ($function eq 'EchoUrl') {
		$response = HTTP::Response->new(200, 'OK', undef, "+:var url = '$url'; url;");
	}
	else {
		$response = HTTP::Response->new(200, 'OK', undef, "-:$function not callable");
	}

	return $response;
};

# Mock the get request
$fake_ua->mock(get => sub {
	my ($self, $url) = @_;

	# Get the called function name
	my $function  = $url->query_param('rs');
	my @arguments = $url->query_param('rsargs[]');

	return $process_request->($function, \@arguments, $url);
});

$fake_ua->mock(post => sub {
	my ($self, $url, $post_data) = @_;

	# Get the called function name
	my $function  = $post_data->{rs};
	my $arguments = $post_data->{'rsargs[]'};

	return $process_request->($function, $arguments, $url);
});

# Say the fake user agent is a LWP::UserAgent
$fake_ua->set_isa('LWP::UserAgent');

use Net::SAJAX;

###########################################################################
# CONSTRUCT SAJAX OBJECT
my $sajax = new_ok('Net::SAJAX' => [
	url => 'http://example.net/app.php',
	user_agent => $fake_ua,
], 'Object creation');

###########################################################################
# CHECK PROPER REQUEST URLS [GET]
{
	# Check the function name was included
	like($sajax->call(function => 'EchoUrl', method => 'GET'),
		qr{rs=EchoUrl}msx, '[GET ] Function name in URL');

	# Check argument was included
	like($sajax->call(function => 'EchoUrl', method => 'GET', arguments => [400]),
		qr{rsargs(?i:%5b%5d)=400}msx, '[GET ] Argument in URL');
}

###########################################################################
# CHECK PROPER REQUEST URLS [POST]
{
	# Check the function name was not included
	unlike($sajax->call(function => 'EchoUrl', method => 'POST'),
		qr{rs=EchoUrl}msx, '[POST] Function name not in URL');

	# Check argument was not included
	unlike($sajax->call(function => 'EchoUrl', method => 'POST', arguments => [400]),
		qr{rsargs(?i:%5b%5d)=400}msx, '[POST] Argument not in URL');
}

###########################################################################
# Change the app URL to include a query parameter
$sajax->url('http://example.net/app.php?key=jabber');

###########################################################################
# CHECK PROPER REQUEST URLS [GET]
{
	# Check the custom query was included
	like($sajax->call(function => 'EchoUrl', method => 'GET'),
		qr{key=jabber}msx, '[GET ]Custom query in URL');
}

###########################################################################
# CHECK PROPER REQUEST URLS [POST]
{
	# Check the custom query was included
	like($sajax->call(function => 'EchoUrl', method => 'POST'),
		qr{key=jabber}msx, '[POST] Custom query in URL');
}
