#Revision history for Collectd-Plugins-Riemann

## 0.2.1 Mon Apr 27 12:40:27 CEST 2015

* add requirements to Makefile: version and Collectd::Plugins::Common
* add second level requirements that fail to resolve on an EL6 system

## 0.2.0 Thu Apr 23 16:47:21 CEST 2015

* user can now control how to build collectd value metadata
* improve documentation
* warn when riemann_ttl < collectd_interval

## 0.1.0 Mon Jan 12 12:36:26 CET 2015
Fix bug where values were not being dispatched if == 0

## 0.1.0 Mon Jan 12 12:36:26 CET 2015
Initial release

