#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

require 'log4r'

module VagrantPlugins
  module HP
    module Action
      # This deletes the running server, if there is one.
      class DeleteServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_hp::action::delete_server')
        end

        def call(env)
          if env[:machine].id
            config = env[:machine].provider_config
            if not config.floating_ip
              @logger.info(I18n.t('vagrant_hp.deleting_floating_ip'))
              ip = env[:hp_compute].addresses.find { |ip| ip.instance_id==env[:machine].id }
              ip.destroy
            end
            @logger.info(I18n.t('vagrant_hp.deleting_server'))
            server = env[:hp_compute].servers.get(env[:machine].id)
            server.destroy
            env[:machine].id = nil
          end
          @app.call(env)
        end
      end
    end
  end
end
