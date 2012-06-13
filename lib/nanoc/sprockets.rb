require 'nanoc'
require 'sprockets'
require 'tilt'

require 'nanoc/sprockets/asset_paths'
require 'nanoc/sprockets/compiler'
require 'nanoc/sprockets/configuration'
require 'nanoc/sprockets/context'
require 'nanoc/sprockets/sass_template'
require 'nanoc/sprockets/scss_template'
require 'nanoc/sprockets/version'

require 'nanoc/data_sources/sprockets'
require 'nanoc/filters/sprockets'
require 'nanoc/helpers/sprockets'

module Nanoc::Sprockets

  class << self

    attr_accessor :context

    def autocompile_source
      path = File.expand_path('../cli/commands/autocompile-sprockets.rb', __FILE__)
      File.read path
    end
    
    def context(site = nil)
      @context ||= begin
        raise "Site must be defined" unless site
        ::Nanoc::Sprockets::Context.new site
      end
    end

  end

end

class Nanoc::Compiler
  alias :run_nanoc :run
  def run(*args)
    run_nanoc
    ::Nanoc::Sprockets.context(site).compiler.compile
  end
end

module ::Sprockets
  register_engine '.sass', ::Nanoc::Sprockets::SassTemplate
  register_engine '.scss', ::Nanoc::Sprockets::ScssTemplate
end
