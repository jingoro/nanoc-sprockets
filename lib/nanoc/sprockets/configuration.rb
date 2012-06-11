module Nanoc::Sprockets
  DEFAULT_OPTIONS = {
    app_root: '.',
    debug: false,
    digest: true,
    compile: true,
    compress: false,
    host: nil,
    manifest_path: 'output/assets',
    paths: %w[images javascripts stylesheets],
    precompile: [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ],
    prefix: 'assets',
    relative_url_root: '',
    css_compressor: false,
    js_compressor: false
  }

  class Configuration < Struct.new(*DEFAULT_OPTIONS.keys)
    attr_accessor *DEFAULT_OPTIONS.keys, :digests

    def initialize
      DEFAULT_OPTIONS.each do |key, value|
        send "#{key}=".to_sym, value
      end
      @digests = {}
    end
  end
end
