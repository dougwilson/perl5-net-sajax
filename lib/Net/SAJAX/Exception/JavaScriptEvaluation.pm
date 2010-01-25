package Net::SAJAX::Exception::JavaScriptEvaluation;

use 5.008003;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.104';

###############################################################################
# MOOSE
use Moose 0.77;
use MooseX::StrictConstructor 0.08;

###############################################################################
# BASE CLASS
extends q{Net::SAJAX::Exception};

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

###############################################################################
# ATTRIBUTES
has javascript_error => (
	is            => 'ro',
	isa           => 'JE::Object::Error',
	documentation => q{The JavaScript evaluation error which occurred},
	required      => 1,
);
has javascript_string => (
	is            => 'ro',
	isa           => 'Str',
	documentation => q{The JavaScript string that was evaluated},
	required      => 1,
);

###############################################################################
# MAKE MOOSE OBJECT IMMUTABLE
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::SAJAX::Exception::JavaScriptEvaluation - Exception object for exceptions
that occur when evaluating JavaScript.

=head1 VERSION

This documentation refers to L<Net::SAJAX::Exception::JavaScriptEvaluation>
version 0.104

=head1 SYNOPSIS

  use Net::SAJAX::Exception::JavaScriptEvaluation;

  Net::SAJAX::Exception::JavaScriptEvaluation->throw(
    message           => 'This is some error message',
    javascript_error  => $je_error_object,
    javascript_string => $javascript,
  );

=head1 DESCRIPTION

This is an exception class for exceptions that occur during evaluation of
JavaScript in the L<Net::SAJAX> library.

=head1 INHERITANCE

This class inherits from the base class of L<Net::SAJAX::Exception> and all
attributes and methods in that class are also in this class.

=head1 ATTRIBUTES

=head2 javascript_error

B<Required>. This is a L<JE::Object::Error> object that contains the error
that was generated by L<JE> while evaluating a string of JavaScript.

=head2 javascript_string

B<Required>. This is a string that contains the JavaScript that was being
evaluated when the error occurred.

=head1 METHODS

This class does not contain any methods.

=head1 DEPENDENCIES

=over

=item * L<Moose> 0.77

=item * L<MooseX::StrictConstructor> 0.08

=item * L<Net::SAJAX::Exception>

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
