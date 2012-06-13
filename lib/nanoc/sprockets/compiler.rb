module Nanoc::Sprockets

  class Compiler

    attr_reader :context, :config

    def initialize(context)
      p 'compiler initialize'
      @context = context
      @config = context.config
    end

    def compile
      @manifest = {}
      context.environment.each_logical_path do |logical_path|
        next unless compile_path?(logical_path)
        asset = context.environment.find_asset(logical_path)
        compile_asset(asset) if asset
      end
      write_manifest if config.manifest
    end

    def compile_asset(asset)
      start_time    = Time.now
      logical_path  = asset.logical_path
      relative_path = asset.digest_path
      path          = File.join(config.target, relative_path)
      if File.exist?(path)
        existing_mtime = File.mtime(path)
        check_assets = [asset] + asset.dependencies
        return if check_assets.all? { |a| a.mtime <= existing_mtime }
      end
      @manifest[logical_path] = relative_path
      action =
        if File.exist?(path)
          if File.open(path).read == asset.to_s
            :identical
          else
            :update
          end
        else
          :create
        end
      FileUtils.mkdir_p File.dirname(path)
      asset.write_to path
      asset.write_to "#{path}.gz" if path.to_s =~ /\.(css|js)$/
      duration = Time.now - start_time
      Nanoc::CLI::Logger.instance.file(:high, action, path, duration)
    end

    def write_manifest
      manifest_path = "#{config.manifest_path}/manifest.yml"
      FileUtils.mkdir_p File.dirname(manifest_path)
      File.open("#{manifest_path}", 'wb') do |f|
        YAML.dump @manifest, f
      end
    end

    def compile_path?(logical_path)
      answer = false
      config.compile_paths.each do |path|
        case path
        when Regexp
          answer = path.match(logical_path)
        when Proc
          answer = path.call(logical_path)
        else
          answer = File.fnmatch(path.to_s, logical_path)
        end
        break if answer
      end
      !!answer
    end

  end
end
