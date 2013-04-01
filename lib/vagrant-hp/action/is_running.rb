#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

module VagrantPlugins
  module HP
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class IsRunning
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].state.id != :running
          @app.call(env)
        end
      end
    end
  end
end
