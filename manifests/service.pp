# Definition: st2::service
#
#  Helper class to setup subsystem services on different operating systems
#
# Description
#
#  This class is designed to assess what init system is in place, and then
#  lay down the appropirate config.
#
# Example
#
#  ::st2::service { 'st2actionrunner': }
define st2::service (
  $subsystem = $name,
) {
  $_provider = $::st2::params::provider

  case $_provider {
    'upstart': {
      $_init_file = "/etc/init/${subsystem}.conf"
      $_init_source = "puppet:///modules/st2/etc/init/${subsystem}.conf"
      $_init_mode = '0444'
    }
    'systemd': {
      $_init_file = "/etc/systemd/system/${subsystem}.service"
      $_init_source = "puppet:///modules/st2/etc/systemd/system/${subsystem}.service"
      $_init_mode = '0444'
    }
    default: {
      $_init_file = "/etc/init.d/${subsystem}"
      $_init_source = "puppet:///modules/st2/etc/init.d/${subsystem}"
      $_init_mode = '0755'
    }
  }

  file { $_init_file:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => $_init_mode,
    source => $_init_source,
  }

  service { $subsystem:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $provider,
    require    => File[$_init_file],
    tag        => ['st2', $subsystem],
  }
}
