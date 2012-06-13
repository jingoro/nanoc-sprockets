module Nanoc::Sprockets

  class Context

    attr_reader :site

    def initialize(site)
      @site = site
      ::Nanoc::Sprockets.context = self
    end

    def environment
      @environment ||= begin
        p 'sprockets environment'
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
        compass_frameworks = ::Compass::Frameworks::ALL rescue []
        compass_frameworks.each do |framework|
          sprockets.append_path "#{framework.stylesheets_directory}"
        end

        if config.compress
          sprockets.css_compressor = compressor config.css_compressor
          sprockets.js_compressor = compressor config.js_compressor
        end
        sprockets
      end
    end

    def config
      @config ||= ::Nanoc::Sprockets::Configuration.new self
    end

    def compiler
      @complier ||= ::Nanoc::Sprockets::Compiler.new self
    end

    def asset_paths
      @asset_paths ||= ::Nanoc::Sprockets::AssetPaths.new self
    end

    def digests
      @digests ||= {}
    end

  private

    def compressor(name)
      case name.to_sym
      when :uglifier
        require 'uglifier'
        Uglifier.new :mangle => true
      when :yui
        require 'yui/compressor'
        YUI::CssCompressor.new
      when nil, false
        nil
      else
        raise "Unknown compressor #{name}"
      end
    end

  end

end
