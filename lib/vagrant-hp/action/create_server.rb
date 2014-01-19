#
# Author:: Mohit Sethi (<mohit@sethis.in>)
# Copyright:: Copyright (c) 2013 Mohit Sethi.
#

require 'vagrant/util/retryable'
require 'log4r'

module VagrantPlugins
  module HP
    module Action
      # This creates server on HP Cloud.
      class CreateServer
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_hp::action::create_server')
        end

        def call(env)
          # Get the configs
          config   = env[:machine].provider_config

          # Find the flavor
          env[:ui].info(I18n.t('vagrant_hp.finding_flavor'))
          flavor = find_match(env[:hp_compute].flavors.all, config.flavor)
          raise Errors::NoMatchingFlavor unless flavor

          # Find the image
          env[:ui].info(I18n.t('vagrant_hp.finding_image'))
          image = find_match(env[:hp_compute].images, config.image)
          raise Errors::NoMatchingImage unless image

          # Figure out the name for the server
          server_name = config.server_name || env[:machine].name if \
                          env[:machine].name != 'default' || get_server_name

          # Output the settings we're going to use to the user
          env[:ui].info(I18n.t('vagrant_hp.launching_server'))
          env[:ui].info(" -- Flavor: #{flavor.name}")
          env[:ui].info(" -- Image: #{image.name}")
          env[:ui].info(" -- Name: #{server_name}")
          env[:ui].info(" -- Key-name: #{config.keypair_name}")
          if config.security_groups
            env[:ui].info(" -- Security Groups: #{config.security_groups}")
          end

          # Build the options for launching...
          options = {
            flavor_id:       flavor.id,
            image_id:        image.id,
            name:            server_name,
            key_name:        config.keypair_name,
            security_groups: config.security_groups
          }

          # Create the server
          server = env[:hp_compute].servers.create(options)

          # Store the ID right away so we can track it
          env[:machine].id = server.id

          # Wait for the server to finish building
          env[:ui].info(I18n.t('vagrant_hp.waiting_for_build'))
          retryable(on: Timeout::Error, tries: 200) do
            # If we're interrupted don't worry about waiting
            next if env[:interrupted]

            # Set the progress
            env[:ui].clear_line
            env[:ui].report_progress(server.progress, 100, false)

            # Wait for the server to be ready
            begin
              server.wait_for(30) { ready? }
            rescue RuntimeError, Fog::Errors::TimeoutError => e
              # If we don't have an error about a state transition, then
              # we just move on.
              # raise if e.message !~ /should have transitioned/
              env[:ui].info("Error: #{e.message}")
            end
          end
          env[:ui].clear_line
          env[:ui].info(I18n.t('vagrant_hp.associate_floating_ip_to_server'))
          ip = env[:hp_compute].addresses.create
          ip.server = server
          unless env[:interrupted]
            # Clear the line one more time so the progress is removed
            env[:ui].clear_line

            # Wait for SSH to become available
            env[:ui].info(I18n.t('vagrant_hp.waiting_for_ssh'))
            while true
              begin
                # If we're interrupted then just back out
                break if env[:interrupted]
                break if env[:machine].communicate.ready?
              rescue Errno::ENETUNREACH
              end
              sleep 2
            end

            env[:ui].info(I18n.t('vagrant_hp.ready'))
          end

          @app.call(env)
        end

        protected

        # generate a random name if server_name is empty
        def get_server_name
          server_name = "vagrant_hp-#{rand.to_s.split('.')[1]}"
          server_name.to_s
        end

        def find_match(collection, name)
          collection.each do |single|
            return single if single.id == name
            return single if single.name == name
          end
          nil
        end
      end
    end
  end
end
