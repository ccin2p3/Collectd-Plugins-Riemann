package Collectd::Plugins::Riemann;

require 5.008002;
use version;

=head1 NAME

Collectd::Plugins::Riemann - Collectd plugins for Riemann.

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

our $VERSION = version->parse('v0.2.1');

1;

