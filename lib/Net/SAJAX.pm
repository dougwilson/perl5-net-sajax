package Net::SAJAX;

use 5.008003;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.101';

###############################################################################
# MOOSE
use Moose 0.77;
use MooseX::StrictConstructor 0.08;

###############################################################################
# MOOSE TYPES
use MooseX::Types::URI 0.02 qw(Uri);

###############################################################################
# MODULE IMPORTS
use English qw(-no_match_vars);
use JE 0.033;
use List::MoreUtils qw(any);
use LWP::UserAgent 5.819;
use URI 1.22;
use URI::QueryParam;

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

###############################################################################
# ATTRIBUTES
has javascript_engine => (
	is  => 'ro',
	isa => 'JE',
	default => sub { JE->new(max_ops => 1000) },
);
has send_rand_key => (
	is  => 'rw',
	isa => 'Bool',
	default => 0,
);
has target_id => (
	is => 'rw',
	isa => 'Str',
	clearer   => 'clear_target_id',
	predicate => 'has_target_id',
);
has url => (
	is  => 'rw',
	isa => Uri,
	coerce   => 1,
	required => 1,
);
has user_agent => (
	is  => 'rw',
	isa => 'LWP::UserAgent',
	default => sub { LWP::UserAgent->new },
);

###############################################################################
# METHODS
sub call {
	my ($self, %args) = @_;

	# Splice out the variables
	my ($function, $arguments, $method)
		= @args{qw(function arguments method)};

	# Set the default value for method. Perl 5.8 doesn't know //=
	$method ||= 'GET';

	if (!defined $function) {
		# No function was specified
		confess 'No function was specified to call';
	}

	# Change the method to uppercase
	$method = uc $method;

	if ($method ne 'GET' && $method ne 'POST') {
		# SAJAX only supports GET and POST
		confess 'SAJAX only supports the GET and POST methods';
	}

	if (defined $arguments) {
		if (ref $arguments ne 'ARRAY') {
			# Arguments must refer to an ARRAYREF
			confess 'Must pass arguments as an ARRAYREF';
		}

		if(any {ref $_ ne q{}} @{$arguments}) {
			# No argument can be a reference
			confess 'No arguments can be a reference';
		}
	}

	# Clone the URL
	my $call_url = $self->url->clone;

	# Build the SAJAX arguments
	my %sajax_arguments = (rs => $function);

	if ($self->has_target_id) {
		# Add the target ID
		$sajax_arguments{rst} = $self->target_id;
	}

	if ($self->send_rand_key) {
		# Add in a random key to the request
		$sajax_arguments{rsrnd} = scalar time;
	}

	if (defined $arguments) {
		# Add the arguments to the request
		$sajax_arguments{'rsargs[]'} = $arguments;
	}

	my $response;

	if ($method eq 'GET') {
		# Add the SAJAX arguments to the URL for a GET request
		$call_url->query_form_hash(%{$call_url->query_form_hash}, %sajax_arguments, );

		# Make the request
		$response = $self->user_agent->get($call_url);
	}
	else {
		# Make the POST request
		$response = $self->user_agent->post($call_url, \%sajax_arguments);
	}

	if (!$response->is_success) {
		# The response was not successful
		confess 'An error occurred in the response';
	}

	# Trim leading and trailing whitespace and get the status and data
	my ($status, $data) = $response->content
		=~ m{\A \s* (.) . (.*?) \s* \z}msx;

	if (!defined $status) {
		# The response was bad
		confess 'Recieved a bad response';
	}
	elsif ($status eq q{-}) {
		# This is an error
		confess 'Recieved error message: ' . $data;
	}

	# Evaluate the data
	$data = $self->javascript_engine->eval($data);

	if ($EVAL_ERROR) {
		# JavaScript error when running code
		confess sprintf 'JavaScript error running code: %s', scalar $EVAL_ERROR;
	}

	return $self->_unwrap_je_object($data);
}

###############################################################################
# PRIVATE METHODS
sub _unwrap_je_object {
	my ($self, $je_object) = @_;

	# Specify the HASH that maps object types with a subroutine that will
	# convert the object into a Perl scalar.
	my %object_value_map = (
		'JE::Boolean'   => sub { return shift->value },
		'JE::LValue'    => sub { return $self->_unwrap_je_object(shift->get) },
		'JE::Null'      => sub { return shift->value },
		'JE::Number'    => sub { return shift->value },
		'JE::String'    => sub { return shift->value },
		'JE::Undefined' => sub { return shift->value },
		'JE::Object'    => sub {
			my $hash_ref = shift->value;

			# Iterate through each HASH element and unwrap the value
			foreach my $key (keys %{$hash_ref}) {
				$hash_ref->{$key} = $self->_unwrap_je_object($hash_ref->{$key});
			}

			return $hash_ref;
		},
		'JE::Object::Array'  => sub {
			return [ map { $self->_unwrap_je_object($_) } @{shift->value} ];
		},
		'JE::Object::Number' => sub { return shift->value },
		'JE::Object::RegExp' => sub { return shift->value },
	);

	# Get the code reference for converting the object
	my $convert_coderef = $object_value_map{ref $je_object};

	if (!defined $convert_coderef) {
		confess sprintf 'Unable to unwrap %s', ref $je_object;
	}

	return $convert_coderef->($je_object);
}

###############################################################################
# MAKE MOOSE OBJECT IMMUTABLE
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::SAJAX - Interact with remote applications that use SAJAX.

=head1 VERSION

This documentation refers to L<Net::SAJAX> version 0.101

=head1 SYNOPSIS

  # Construct a SAJAX interaction object
  my $sajax = Net::SAJAX->new(
    url => URI->new('https:/www.example.net/my_sajax_app.php'),
  );

  # Make a SAJAX call
  my $product_name = $sajax->call(
    function  => 'GetProductName',
    arguments => [67632],
  );

  print "The product $product_name is out of stock\n";

  # Make a SAJAX call using POST (usually for big or sensitive data)
  my $result = $sajax->call(
    function  => 'SetPassword',
    method    => 'POST',
    arguments => ['My4w3s0m3p4sSwOrD'],
  );

  if ($result->{result} == 1) {
    print "Your password was successfully changed\n";
  }
  else {
    printf "An error occurred when setting your password: %s\n",
      $result->{error_message};
  }

=head1 DESCRIPTION

Provides a way to interact with applications that utilize the SAJAX library
found at L<http://www.modernmethod.com/sajax/>.

=head1 CONSTRUCTOR

This is fully object-oriented, and as such before any method can be used, the
constructor needs to be called to create an object to work with.

=head2 new

This will construct a new object.

=over

=item B<new(%attributes)>

C<%attributes> is a HASH where the keys are attributes (specified in the
L</ATTRIBUTES> section).

=item B<new($attributes)>

C<$attributes> is a HASHREF where the keys are attributes (specified in the
L</ATTRIBUTES> section).

=back

=head1 ATTRIBUTES

=head2 javascript_engine

This is a L<JE> object that is used to evaluate the JavaScript data recieved.
Since this is a custom engine in Perl, the JavaScript executed should not have
any security affects. This defaults to C<< JE->new(max_ops => 1000) >>.

=head2 send_rand_key

This is a Boolean of if to send a random key with the request. This is part of
the SAJAX library and is provided for use. The default for the SAJAX library
is to send the random key, but that is an unnecessary method to get around
caching issues, and so is it off by default.

  # Enable sending of a random key
  $sajax->send_rand_key(1);

  # Toggle the setting
  $sajax->send_rand_key(!$sajax->send_rand_key());

=head2 target_id

This is a string that specified the target element ID that the response would
normally be added to. This is completely unnecessary in this library, but
since it is send with the request, it is possible this could affect the data
that is returned. This defaults to nothing and no target ID is sent with the
request.

  # Change the target ID
  $sajax->target_id('content');

  # Clear the target ID (restroing default behavour)
  $sajax->clear_target_id();

Using L</has_target_id>, it can be determined if a target ID is currently
set on the object. Using L</clear_target_id> the target ID will be cleared
from the object, restroing default behavour.

=head2 url

B<required>

This is a L<URI> object of the URL of the SAJAX application.

=head2 user_agent

This is the L<LWP::UserAgent> object to use when making requests. This is
provided to handle custom user agents. The default value is LWP::UserAgent
constructed with no arguments.

  # Set a low timeout value
  $sajax->user_agent->timeout(10);

=head1 METHODS

=head2 call

This method will preform a call to a remote function using SAJAX. This will
return a Perl scalar representing the returned data. Please note that this by
returning a scalar, that includes references.

  # call may return an ARRAYREF for an array
  my $array_ref = $sajax->call(function => 'IReturnAnArray');
  print 'Returned: ', join q{,}, @{$array_ref};

  # call may return a HASHREF for an object
  my $hash_ref = $sajax->call(function => 'IReturnAnObject');
  print 'Error value: ', $hash_ref->{error};

  # There may even be a property of an object that is an array
  my $object = $sajax->call(function => 'GetProductInfo');
  printf "Product: %s\nPrices: %s\n",
    $object->{name},
    join q{, }, @{$object->{prices}};

This method takes a HASH with the following keys:

=over

=item arguments

This is an ARRAYREF that specifies what arguments to send with the function
call. This must not contain any references (essentially only strings and
numbers). If not specified, then no arguments are sent.

=item function

B<required>

This is a string with the function name to call.

=item method

This is a string that is either C<"GET"> or C<"POST">. If not supplied, then
the method is assumed to be C<"GET">, as this is the most common SAJAX method.

=back

=head1 VERSION NUMBER GUARANTEE

This module has a version number in the format of C<< \d+\.\d{3} >>. When the
digit to the left of the decimal point is incremented, this means that this
module was changed in such a way that it will very likely break code that uses
it. Please see L<Net::SAJAX::VersionGuarantee>.

=head1 DEPENDENCIES

=over 4

=item * L<English>

=item * L<JE> 0.033

=item * L<List::MoreUtils>

=item * L<LWP::UserAgent> 5.819

=item * L<Moose> 0.77

=item * L<MooseX::StrictConstructor> 0.08

=item * L<MooseX::Types::URI> 0.02

=item * L<URI> 1.22

=item * L<URI::QueryParam>

=item * L<namespace::clean> 0.04

=back

=head1 AUTHOR

Douglas Christopher Wilson, C<< <doug at somethingdoug.com> >>

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to C<bug-net-sajax at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-SAJAX>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

I highly encourage the submission of bugs and enhancements to my modules.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc Net::SAJAX

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-SAJAX>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-SAJAX>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-SAJAX>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-SAJAX/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2009 Douglas Christopher Wilson.

This program is free software; you can redistribute it and/or
modify it under the terms of either:

=over 4

=item * the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or

=item * the Artistic License version 2.0.

=back
