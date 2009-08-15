use inc::Module::Install;

name     'Net-SAJAX';
all_from 'lib/Net/SAJAX.pm';
author   'Douglas Christopher Wilson <doug@somethingdoug.com>';
license  'perl';
resources homepage   => 'http://github.com/dougwilson/perl5-net-sajax/';
resources repository => 'git://github.com/dougwilson/perl5-net-sajax.git';

build_requires 'Test::Exception' => '0.03';
build_requires 'Test::More'      => '0.41';

requires 'English'                   => 0;
requires 'JE'                        => '0.033';
requires 'List::MoreUtils'           => 0;
requires 'LWP::UserAgent'            => '5.819';
requires 'Moose'                     => '0.77';
requires 'MooseX::StrictConstructor' => '0.08';
requires 'MooseX::Types::URI'        => '0.02';
requires 'URI'                       => '1.22';
requires 'URI::QueryParam'           => 0;
requires 'namespace::clean'          => '0.04';

author_requires 'File::Spec'            => 0;
author_requires 'Pod::Coverage'         => '0.18';
author_requires 'Test::CleanNamespaces' => 0;
author_requires 'Test::DistManifest'    => 0;
author_requires 'Test::MinimumVersion'  => '0.009';
author_requires 'Test::Perl::Critic'    => 0;
author_requires 'Test::Pod'             => '1.22';
author_requires 'Test::Pod::Coverage'   => '1.08';

# Enable tests to be in multi-level directories
tests_recursive;

# Author tests in xt/
recursive_author_tests('xt');

WriteAll;

