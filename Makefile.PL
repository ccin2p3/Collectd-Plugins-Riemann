use inc::Module::Install;

name     'Collectd-Plugins-Riemann';
all_from 'lib/Collectd/Plugins/Riemann.pm';
author   q{Fabien Wernli <wernli@in2p3.fr>};
license  'CeCILL';

test_requires 'Test::More';
test_requires 'Test::MockModule';
test_requires 'Test::Collectd::Plugins' => '0.1007';

requires 'Collectd';
requires 'Riemann::Client';

install_share qw(share);

# auto_install;

WriteAll;

