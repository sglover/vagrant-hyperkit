module VagrantPlugins
  module HYPERKIT
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class IsCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].id != nil
          @app.call(env)
        end
      end
    end
  end
end
