module Nanoc::Sprockets
  class ScssTemplate < Tilt::ScssTemplate
    def sass_options
      super.merge :load_paths => ::Nanoc::Sprockets.context.environment.paths
    end
  end
end
