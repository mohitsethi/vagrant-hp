#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

require "fog"
require "log4r"

module VagrantPlugins
  module HP
    module Action
      # This action connects to HP, verifies credentials work, and
      # puts the HP connection object into the `:hp_compute` key
      # in the environment.
      class ConnectHP
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_hp::action::connect_hp")
        end

        def call(env)
          # Get the configs
          config = env[:machine].provider_config
          access_key = config.access_key
          secret_key = config.secret_key
          tenant_id = config.tenant_id
          availability_zone = availability_zone(config.availability_zone)

          @logger.info("Connecting to HP...")
          env[:hp_compute] = Fog::Compute.new({
            :provider => :hp,
            :hp_access_key => access_key,
            :hp_secret_key => secret_key,
            :hp_tenant_id => tenant_id,
            :hp_avl_zone => availability_zone,
          })

          @app.call(env)
        end

        def availability_zone(availability_zone)
          case availability_zone
          when 'az3'
            return 'az-3.region-a.geo-1'
          when 'az2'
            return 'az-2.region-a.geo-1'
          else
            return 'az-1.region-a.geo-1'
          end
        end
      end
    end
  end
end
