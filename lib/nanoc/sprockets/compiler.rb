module Nanoc::Sprockets
  class Compiler

    def initialize
      @target = 'output/assets'
      @manifest = true
      @manifest_path = "#{@target}/manifest.yml"
      @paths = ['application.js', 'application.css']
    end
    
    def compile
      @manifest = {}
      env = ::Nanoc::Sprockets.environment
      env.each_logical_path do |logical_path|
        next unless compile_path?(logical_path)
        asset = env.find_asset(logical_path)
        compile_asset(asset) if asset
      end
      write_manifest
    end

    def compile_asset(asset)
      start_time    = Time.now
      logical_path  = asset.logical_path
      relative_path = asset.digest_path
      path          = File.join(@target, relative_path)
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
      asset.write_to(path)
      asset.write_to("#{path}.gz") if path.to_s =~ /\.(css|js)$/
      duration = Time.now - start_time
      Nanoc::CLI::Logger.instance.file(:high, action, path, duration)
    end

    def write_manifest
      FileUtils.mkdir_p(File.dirname(@manifest_path))
      File.open("#{@manifest_path}", 'wb') do |f|
        YAML.dump(@manifest, f)
      end
    end

    def compile_path?(logical_path)
      answer = false
      @paths.each do |path|
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
