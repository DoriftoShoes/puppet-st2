# == Class: st2::params
#
#  Main parameters to manage the st2 module
#
# === Parameters
#  [*robots_group_name*] - The name of the group created to hold the st2 admin user
#  [*robots_group_id*] - The GID of the group created to hold the st2 admin user.
#
# === Variables
#  [*repo_url*] - The URL where the StackStorm project is hosted on GitHub
#  [*conf_dir*] - The local directory where st2 config is stored
#  [*subsystems*] - Different executable subsystems within StackStorm
#  [*component_map*] - Hash table of mappings of Subsystems -> Components
#  [*st2_server_packages*] - A list of all upstream server packages to grab from upstream package server
#  [*st2_client_packages*] - A list of all upstream client packages to grab from upstream package server
#  [*debian_dependencies*] - Any dependencies needed to successfully run st2 server on the Debian OS Family
#  [*debian_client_dependencies*] - Any dependencies needed to successfully run st2 client on the Debian OS Family
#  [*debian_mongodb_dependencies*] - MongoDB Dependencies (if installed via this module)
#  [*redhat_dependencies*] - Any dependencies needed to successfully run st2 server on the RedHat OS Family
#  [*redhat_client_dependencies*] - Any dependencies needed to successfully run st2 client on the RedHat OS Family
#
# === Examples
#
#  include st2::params
#
#  class { 'st2::params':
#
#  }
#

class st2::params(
  $robots_group_name = 'st2robots',
  $robots_group_gid  = 800,
) {
  $subsystems = [
    'actionrunner', 'api', 'sensorcontainer',
    'rulesengine', 'resultstracker', 'notifier',
    'auth'
  ]

  $component_map = {
    actionrunner    => 'st2actions',
    api             => 'st2api',
    auth            => 'st2auth',
    notifier        => 'st2actions',
    resultstracker  => 'st2actions',
    rulesengine     => 'st2reactor',
    sensorcontainer => 'st2reactor',
  }

  # Non-user configurable parameters
  $repo_url = 'https://github.com/StackStorm/st2'
  $conf_dir = '/etc/st2'

  $st2_server_packages = [
    'st2common',
    'st2reactor',
    'st2actions',
    'st2api',
    'st2auth',
    'st2debug',
  ]
  $st2_client_packages = [
    'python-st2client',
  ]

  ### Debian Specific Information ###
  $debian_dependencies = [
    'make',
    'realpath',
    'gcc',
    'python-yaml',
    'libssl-dev',
    'libyaml-dev',
    'libffi-dev',
    'libxml2-dev',
    'libxslt1-dev',
    'python-tox',
  ]
  $debian_client_dependencies = [
    'python-prettytable',
    'python-jsonpath-rw',
    'python-dateutil',
  ]
  $debian_mongodb_dependencies = [
    'mongodb-dev',
  ]
  ### END Debian Specific Information ###

  ### RedHat Specific Information ###
  $redhat_dependencies = [
    'gcc-c++',
    'openssl-devel',
    'libyaml-devel',
    'libffi-devel',
    'libxml2-devel',
    'libxslt-devel',
  ]
  $redhat_client_dependencies = [
    'python-prettytable',
  ]
  ### END RedHat Specific Information ###

  # Detect init type
  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
            $provider = 'systemd'
          } else {
            $provider = 'init'
          }
        }
        'Ubuntu': {
          if versioncmp($::operatingsystemrelease, '15.04') >= 0 {
            $provider = 'systemd'
          } else {
            $provider = 'upstart'
          }
        }
        default: {
          fail('StackStorm does not know what Debian based OS this is.')
        }
      }
    }
    'RedHat': {
      if ($::operatingsystem == 'Fedora') or
         (versioncmp($::operatingsystemrelease, '7.0') >= 0) {
        $provider = 'systemd'
      } else {
        $template = 'init'
      }
    }
    default: {
      fail('StackStorm needs a Debian or RedHat based system.')
    }
  }
}
