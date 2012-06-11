module Nanoc::Helpers
  module Sprockets

    def javascript_include_tag(*sources)
      options = sprockets_extract_options!(sources)
      debug   = options.delete(:debug) { sprockets_config.debug }
      body    = options.delete(:body) { false }
      digest  = options.delete(:digest) { sprockets_config.digest }

      sources.collect do |source|
        if debug && asset = asset_paths.asset_for(source, 'js')
          asset.to_a.map do |dep|
            src = asset_path(dep, :ext => 'js', :body => true, :digest => digest)
            "<script src='#{src}' type='text/javascript'></script>"
          end
        else
          src = asset_path(source, :ext => 'js', :body => body, :digest => digest)
          "<script src='#{src}' type='text/javascript'></script>"
        end
      end.uniq.join("\n")
    end

    def stylesheet_link_tag(*sources)
      options = sprockets_extract_options!(sources)
      debug   = options.delete(:debug) { sprockets_config.debug }
      body    = options.delete(:body) { false }
      digest  = options.delete(:digest) { sprockets_config.digest }

      sources.collect do |source|
        if debug && asset = asset_paths.asset_for(source, 'css')
          asset.to_a.map do |dep|
            href = asset_path(dep, :ext => 'css', :body => true, :protocol => :request, :digest => digest)
            "<link href='#{href}' media='screen' rel='stylesheet' type='text/css' />"
          end
        else
          href = asset_path(source, :ext => 'css', :body => body, :protocol => :request, :digest => digest)
          "<link href='#{href}' media='screen' rel='stylesheet' type='text/css' />"
        end
      end.uniq.join("\n")
    end

    def asset_path(source, options = {})
      source = source.logical_path if source.respond_to?(:logical_path)
      path = asset_paths.compute_public_path(source, sprockets_config.prefix, options.merge(:body => true))
      options[:body] ? "#{path}?body=1" : path
    end

    def image_path(source, options = {})
      asset_path source, options
    end

    def javascript_path(source, options = {})
      asset_path source, { ext: 'js' }.merge(options)
    end

    def stylesheet_path(source, options = {})
      asset_path source, { ext: 'css' }.merge(options)
    end

    def asset_paths
      @asset_paths ||= ::Nanoc::Sprockets::AssetPaths.new
    end

  private

    def sprockets_config
      ::Nanoc::Sprockets.config
    end
    
    def sprockets_extract_options!(array)
      array.last.is_a?(::Hash) ? array.pop : {}
    end

  end
end
