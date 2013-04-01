#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

require "vagrant-hp/util/timer"

module VagrantPlugins
  module HP
    module Action
      # This is the same as the builtin provision except it times the
      # provisioner runs.
      class TimedProvision < Vagrant::Action::Builtin::Provision
        def run_provisioner(env, p)
          env[:ui].info("Insde TimedProvision")
          timer = Util::Timer.time do
            super
          end

          env[:metrics] ||= {}
          env[:metrics]["provisioner_times"] ||= []
          env[:metrics]["provisioner_times"] << [p.class.to_s, timer]
        end
      end
    end
  end
end
