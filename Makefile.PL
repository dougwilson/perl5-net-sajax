use inc::Module::Install;

name     'Net-SAJAX';
all_from 'lib/Net/SAJAX.pm';
author   'Douglas Christopher Wilson <doug@somethingdoug.com>';
license  'perl';

# Resources
resources homepage   => 'http://github.com/dougwilson/perl5-net-sajax/';
resources repository => 'git://github.com/dougwilson/perl5-net-sajax.git';

# Modules that are required
requires
	'Carp'                      => 0,
	'English'                   => 0,
	'HTTP::Request::Common'     => '5.814',
	'JE'                        => '0.033',
	'List::MoreUtils'           => 0,
	'LWP::UserAgent'            => '5.819',
	'Moose'                     => '0.77',
	'MooseX::StrictConstructor' => '0.08',
	'MooseX::Types::URI'        => '0.02',
	'URI'                       => '1.22',
	'URI::QueryParam'           => 0,
	'namespace::clean'          => '0.04';

# Modules that are required for tests
test_requires
	'Test::Exception'  => '0.03',
	'Test::MockObject' => 0,
	'Test::More'       => '0.41',
	'URI::Escape'      => 0;

# Modules that are required for author tests
author_requires
	'File::Spec'                      => 0,
	'Module::Install'                 => '0.91',
	'Module::Install::AuthorRequires' => '0.02',
	'Module::Install::AuthorTests'    => '0.002',
	'Pod::Coverage'                   => '0.18',
	'Test::CleanNamespaces'           => 0,
	'Test::ConsistentVersion'         => 0,
	'Test::DistManifest'              => 0,
	'Test::MinimumVersion'            => '0.009',
	'Test::Perl::Critic'              => 0,
	'Test::Pod'                       => '1.22',
	'Test::Pod::Content'              => 0,
	'Test::Pod::Coverage'             => '1.08',
	'Test::Requires'                  => '0.02';

# Enable tests to be in multi-level directories
tests_recursive;

WriteAll;

