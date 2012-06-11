module Nanoc::DataSources
  class Sprockets < Nanoc::DataSource

    identifier :sprockets

    # (see Nanoc::DataSource#setup)
    def setup
    end

    # (see Nanoc::DataSource#items)
    def items
      assets.map do |asset|
        attributes = {
          :logical_path => asset.logical_path,
          :digest => asset.digest,
          :mtime => asset.mtime,
          :pathname => asset.pathname,
        }
        ::Nanoc::Item.new(asset.body, attributes, 'assets/' + asset.logical_path, asset.mtime)
      end
    end

    # (see Nanoc::DataSource#create_item)
    def create_item(content, attributes, identifier, params={})
    end

    # (see Nanoc::DataSource#create_layout)
    def create_layout(content, attributes, identifier, params={})
    end

  private

    def environment
      ::Nanoc::Sprockets.environment
    end
    
    def assets
      environment.each_logical_path.map { |x| environment.find_asset(x) }.compact.uniq
    end

  end
end
