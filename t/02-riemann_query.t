#!perl

use Test::More;
use Test::Collectd::Plugins;
use Riemann::Client::Protocol;
#use Test::MockObject::Extends;
use Test::MockModule;

plan tests => 2;

diag("Testing $nfound Collectd::Plugins::Riemann::Query plugin");
load_ok("Collectd::Plugins::Riemann::Query");
my $mock_collectd_data = [
	{
		service => 'memory/memory-free',
		metric_f => 1.234567,
		host => 'foo',
		attributes => [
			{
				key => 'type',
				value => 'memory',
			},{
				key => 'plugin',
				value => 'memory',
			},{
				key => 'type_instance',
				value => 'free'
			}
		]
	},{
		service => 'foo',
		metric_f => 1.3,
		host => 'plop'
	},{
		service => 'cpu-0/cpu-idle',
		metric_sint64 => 42,
		host => 'foo',
		attributes => [
			{
				key => 'type',
				value => 'cpu',
			},{
				key => 'plugin',
				value => 'cpu',
			},{
				key => 'type_instance',
				value => 'idle'
			},{
				key => 'plugin_instance',
				value => '0'
			},{
				key => 'foo',
				value => 'bar'
			}
		]
	}
];

{
	my $module = Test::MockModule->new('Riemann::Client');
	$module -> mock(
		query => sub {
			Msg -> decode(
				Msg -> encode(
					{ events => $mock_collectd_data }
				)
			)
		}
	);
	read_ok("Collectd::Plugins::Riemann::Query", "riemann_query");
}

