#!perl -T

use Test::More 0.41 tests => 1;

BEGIN {
	use_ok('Net::SAJAX');
}

diag("Testing Net::SAJAX $Net::SAJAX::VERSION, Perl $], $^X");
