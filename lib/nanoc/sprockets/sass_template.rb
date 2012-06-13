module Nanoc::Sprockets
  class SassTemplate < Tilt::SassTemplate
    def sass_options
      super.merge :load_paths => ::Nanoc::Sprockets.context.environment.paths
    end
  end
end
