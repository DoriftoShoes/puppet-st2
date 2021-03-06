# == Class: st2::pack::contrib
#
#  Helper function to clean up Hiera imports
#
# === Parameters
#  [*packs*] - Array of packs to install
#
# === Examples
#
#  include st2::pack::contrib
#
#  class { 'st2::pack::contrib':
#    packs => ['cicd', 'jenkins'],
#  }
#
class st2::pack::contrib(
  $packs = hiera_array('st2::pack::contrib', []),
) {
  $_packs = join($packs, ',')

  st2::pack { $_packs: }
}
