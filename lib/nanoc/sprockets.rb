require 'nanoc'
require 'sprockets'

require 'nanoc/sprockets/asset_paths'
require 'nanoc/sprockets/compiler'
require 'nanoc/sprockets/configuration'

require 'nanoc/data_sources/sprockets'
require 'nanoc/filters/sprockets'
require 'nanoc/helpers/sprockets'

module Nanoc::Sprockets

  def self.environment
    @environment ||= begin
      sprockets = nil
      nanoc_stderr = $stderr
      begin
        $stderr = STDERR
        sprockets = ::Sprockets::Environment.new config.app_root
      ensure
        $stderr = nanoc_stderr
      end
      config.paths.each do |path|
        sprockets.append_path "#{config.app_root}/#{config.prefix}/#{path}"
      end
      if config.compress
        sprockets.css_compressor = config.css_compressor
        sprockets.js_compressor = config.js_compressor
      end
      sprockets
    end
  end

  def self.config
    @config ||= ::Nanoc::Sprockets::Configuration.new
  end

  def self.autocompile_source
    path = File.expand_path('../cli/commands/autocompile-sprockets.rb', __FILE__)
    File.read path
  end

end

class Nanoc::Compiler
  
  alias :run_nanoc :run
  def run(*args)
    ::Nanoc::Sprockets::Compiler.new.compile
    run_nanoc
  end

end
