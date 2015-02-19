package Collectd::Plugins::Riemann::Query;

use strict;
use warnings;

use Collectd qw( :all );
use Collectd::Plugins::Common qw(recurse_config);
use Riemann::Client;
use Try::Tiny;
#use DDP {
#	deparse => 1,
#	class => {
#		expand => 'all'
#	}
#};

my %opt = (
	Server => "127.0.0.1",
	Port => 5555,
	Protocol => 'TCP',
	Query => 'service "riemann%"',
);

=head1 NAME

Collectd::Plugins::Riemann::Query - Collectd plugin for querying Riemann Events

=head1 SYNOPSIS

To be used with L<Collectd>.

=over 8

=item From the collectd configfile

 <LoadPlugin "perl">
   Globals true
 </LoadPlugin>

 <Plugin "perl">
   BaseName "Collectd::Plugins"
   LoadPlugin "Riemann::Query"
   <Plugin "riemann_query">
     Host        myriemann
     Port        5555
     Protocol    TCP
     Query       "tagged \"foo\" and service =~ \"bar%\""
   </Plugin>
 </Plugin>

=back

=head1 SUBROUTINES

Please refer to the L<Collectd> documentation.
Or C<man collectd-perl>

=head1 FILES

/etc/collectd.conf
/etc/collectd.d/

=head1 SEE ALSO

Collectd, collectd-perl, collectd

=cut

my $plugin_name = "riemann_query";
my $r;

plugin_register(TYPE_CONFIG, $plugin_name, 'my_config');
plugin_register(TYPE_READ, $plugin_name, 'my_get');
plugin_register(TYPE_INIT, $plugin_name, 'my_init');

sub my_init {
	1;
}

sub my_log {
	plugin_log shift @_, join " ", "plugin=".$plugin_name, @_;
}

sub my_config {
	my (undef,$o) = recurse_config($_[0]);
	%opt = %$o;
}

sub my_get {
	unless (ref $r eq "Riemann::Client") {
		my_log(LOG_DEBUG, "get: initializing riemann client");
		$r = Riemann::Client->new(
			host => $opt{Host},
			port => $opt{Port},
			proto => $opt{Protocol},
		)
	}
	my_log(LOG_DEBUG, "get: fetching data");

	my $res;
	try {
		$res = $r -> query($opt{Query});
	} catch {
		my_log(LOG_ERR, "get: problem fetching data", $_);
		return;
	};
	unless ($res) {
		my_log(LOG_ERR, "get: empty message");
		return;
	}
	my $events = $res -> {events};
	unless ($events) {
		my_log(LOG_ERR, "get: no events in message");
		return;
	}
	unless (ref $events eq "ARRAY") {
		my_log(LOG_ERR, "get: events not array");
		return;
	}
	for my $event (@$events) {
		my $host = $event -> {host} || "nil";
		_sanitize($host);
		my %plugin;
		for (qw(type type_instance plugin plugin_instance)) {
			if ($_) {
				my $attr = _get_collectd_attribute($event,$_);
				$plugin{$_} = $attr if $attr;
			}
		}
		$plugin{type} ||= 'gauge';
		unless ($plugin{plugin}) {
			my $service = $event -> {service} || "nil";
			_sanitize($service);
			$plugin{plugin} = $service;
		}
		my $metric;
		if ($event -> {metric_d}) {
			$metric = $event -> {metric_d}
		} elsif ($event -> {metric_f}) {
			$metric = $event -> {metric_f}
		} elsif ($event -> {metric_sint64}) {
			$metric = $event -> {metric_sint64}
		} else {
			my $p_s = join(',',%plugin);
			my_log(LOG_DEBUG, "get: event `$p_s` has no metric: ignoring");
		}
		_dispatch($host,\%plugin,$metric);
	}
	1;
}

sub _sanitize ($) {
	map { s/ /_/g } @_;
}

sub _get_collectd_attribute ($$) {
	my ($evt, $key) = @_;
	unless ($evt -> isa('Event')) {
		my_log(LOG_ERR, "_get_collectd_attribute: event is garbled");
		return
	}
	unless ($key) {
		my_log(LOG_ERR, "_get_collectd_attribute: arg2 empty");
		return
	}
	my $attributes = $evt -> {attributes};
	if ($attributes && ref $attributes eq "ARRAY") {
		for my $attr (@$attributes) {
			if ($attr -> {key} eq $key) {
				return $attr -> {value}
			}
		}
	} else {
		my_log(LOG_DEBUG, "_get_collectd_attribute: no attributes for event");
	}
	my_log(LOG_DEBUG, "_get_collectd_attribute: attribute `$key` not found for event");
	return
}

sub _dispatch ($$$) {
	my $host = shift;
	my $p = shift;
	my %plugin = %$p;
	my $metric = shift;
	$plugin{host} = $host;
	$plugin{values} = [ $metric ];
	my $ret = plugin_dispatch_values(\%plugin);
	unless ($ret) {
		my $p_s = join(',',%plugin);
		my_log(LOG_INFO, "dispatch error: `$p_s`") unless ($ret);
	}
	return $ret;
}

1;

