module Nanoc::Sprockets
  class AssetPaths
    class AssetNotPrecompiledError < StandardError; end

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def asset_for(source, ext)
      source = source.to_s
      return nil if is_uri?(source)
      source = rewrite_extension(source, nil, ext)
      asset_environment[source]
    rescue ::Sprockets::FileOutsidePaths
      nil
    end

    def digest_for(logical_path)
      if config.digest && context.digests && (digest = context.digests[logical_path])
        return digest
      end

      if config.compile
        if config.digest && asset = asset_environment[logical_path]
          return asset.digest_path
        end
        return logical_path
      else
        raise AssetNotPrecompiledError.new("#{logical_path} isn't precompiled")
      end
    end

    def rewrite_asset_path(source, dir, options = {})
      # p ['rewrite_asset_path', options.inspect]
      if source[0] == ?/
        source
      else
        source = digest_for(source) unless options[:digest] == false
        source = File.join(dir, source)
        source = "/#{source}" unless source =~ /^\//
        source
      end
    end

    def rewrite_extension(source, dir, ext)
      if ext && File.extname(source) != ".#{ext}"
        "#{source}.#{ext}"
      else
        source
      end
    end

    def compute_public_path(source, dir, options = {})
      source = source.to_s
      unless is_uri?(source)
        source = rewrite_extension(source, dir, options[:ext]) if options[:ext]
        source = rewrite_asset_path(source, dir, options)
        source = rewrite_relative_url_root(source, config.relative_url_root)
        source = rewrite_host_and_protocol(source, options[:protocol])
      end
      source
    end

    def is_uri?(path)
      path =~ %r{^[-a-z]+://|^cid:|^//}
    end

    def rewrite_host_and_protocol(source, protocol = nil)
      host = compute_asset_host(source)
      if host && !is_uri?(host)
        if (protocol || default_protocol) == :request && !has_request?
          host = nil
        else
          host = "#{compute_protocol(protocol)}#{host}"
        end
      end
      host ? "#{host}#{source}" : source
    end

    def rewrite_relative_url_root(source, relative_url_root)
      relative_url_root && !starts_with?(source, "#{relative_url_root}/") ? "#{relative_url_root}#{source}" : source
    end

    def compute_asset_host(source)
      if host = config.host
        if host.respond_to?(:call)
          args = [source]
          arity = arity_of(host)
          if arity > 1 && request.nil?
            invalid_asset_host!("Remove the second argument to your asset_host Proc if you do not need the request.")
          end
          args << current_request if (arity > 1 || arity < 0) && has_request?
          host.call(*args)
        else
          (host =~ /%d/) ? host % (Zlib.crc32(source) % 4) : host
        end
      end
    end

    def default_protocol
      config.default_protocol || (request.nil?? :relative : :request)
    end

    def compute_protocol(protocol)
      protocol ||= default_protocol
      case protocol
      when :request
        if request.nil?
          invalid_asset_host!("The protocol requested was :request. Consider using :relative instead.")
        end
        request.protocol
      when :relative
        "//"
      else
        "#{protocol}://"
      end
    end

    def arity_of(callable)
      callable.respond_to?(:arity) ? callable.arity : callable.method(:call).arity
    end

    def invalid_asset_host!(help_message)
      raise "This asset host cannot be computed without a request in scope. #{help_message}"
    end

    private

    def starts_with?(source, pref)
      prefix = prefix.to_s
      source[0, prefix.length] == prefix
    end

    def asset_environment
      context.environment
    end

    def config
      context.config
    end

  end
end
