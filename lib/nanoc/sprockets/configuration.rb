module Nanoc::Sprockets

  DEFAULT_CONFIGURATION = {
    :app_root       => '.',
    :compress       => false,
    :compile        => true,
    :compile_paths  => [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ],
    :css_compressor => :yui,
    :debug          => false,
    :digest         => true,
    :host           => nil,
    :js_compressor  => :uglifier,
    :manifest       => true,
    :manifest_path  => 'output/assets',
    :paths          => %w[images javascripts stylesheets],
    :prefix         => 'assets',
    :relative_url_root => '',
    :target         => 'output/assets',
  }

  class Configuration < Struct.new(*DEFAULT_CONFIGURATION.keys)
    attr_accessor *DEFAULT_CONFIGURATION.keys
    def initialize(context)
      nanoc_config = context.site.config[:sprockets] || {}
      DEFAULT_CONFIGURATION.each do |key, value|
        send :"#{key}=", nanoc_config[key] || value
      end
    end
  end

end
