# Definition: st2::service::actionrunner
#
#  This defined type is used to simulate a loop in
#  pre-4.0 clients, creating N instances of the
#  st2actionrunner-worker upstart script.
#
#  Usage:
#    st2::service::actionrunner { '1': }
define st2::service::actionrunner (
  $worker_id = $name,
) {
  $_provider = $::st2::params::provider

  case $_provider {
    'upstart': {
      $_init_file = "/etc/init/st2actionrunner-${worker_id}.conf"
      $_init_content = template('st2/etc/init/st2actionrunner-worker.conf.erb')
      $_init_mode = '0444'
    }
    'systemd': {
      $_init_file = "/etc/systemd/system/st2actionrunner-${worker_id}.service"
      $_init_content = template('st2/etc/systemd/system/st2actionrunner-worker.service.erb')
      $_init_mode = '0444'
    }
    default: {
      $_init_file = undef
    }
  }

  if $_init_file {
    file { $_init_file:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => $_init_mode,
      content => $_init_content,
    }
    service { "st2actionrunner-${worker_id}":
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider   => $provider,
      require    => File[$_init_file],
      tag        => ['st2', $subsystem],
    }
  }
}
