require 'nanoc'

module Nanoc
  module Filters
    class Sprockets < Nanoc::Filter

      identifier :sprockets

      # Provides dependency management for Sprockets.
      #
      # This method takes no options.
      #
      # @param [String] content the HTML
      # @return [String] the same HTML
      def run(content, args = {})
        # for now, just depend on every asset...
        # depend_on required_items.uniq if required_items.size > 0
        # p environment.each_logical_path.map { |x| x }
        dependent_items = items.select do |item|
          nanoc_path = item.identifier[1..-2]
          nanoc_path =~ /^assets/
          # p nanoc_path
          # logical_path = nanoc_path[('assets/'.length)..-1]
          # next unless logical_path
          # p find_asset(logical_path).dependencies
        end.uniq
        depend_on dependent_items if dependent_items.size > 0
        content
      end
    
    private
    
      # def environment
      #   Nanoc::Sprockets.environment
      # end
      # 
      # def find_asset(logical_path)
      #   environment.find_asset logical_path
      # end
      #   environment.each_logical_path.map { |x| environment.find_asset(x) }.compact.uniq
      # end

    end
  end
end