# -*- encoding: utf-8 -*-

require 'rexml/document'

module Documatic::OpenDocumentText
  class Partial < Template

    attr_accessor :content
    attr_accessor :filename

    class << self
      def add_partial(name, partial)
        self.cache[name] = partial
      end

      def cache
        @cache ||= Hash.new
      end

      def cache_by_prefix
        by_prefix = Hash.new
        self.cache.each_value do |partial|
          by_prefix[partial.prefix] = partial
        end
        by_prefix
      end
        
      def flush_cache
        @cache = Hash.new
      end
        
    end  # class << self
    
    def initialize(filename, prefix_name = nil)
      super filename
      @prefix = prefix_name || self.prefix
    end

    def process(local_assigns = {})
      self.jar.find_entry('documatic/partial') || self.compile
      @content = Documatic::OpenDocumentText::Component.new( self.content_erb )
      @content.process(local_assigns)
    end

    def compile
      doc = REXML::Document.new( self.jar.read('content.xml') )
      style_names = Hash.new

      # Gather all auto style names from <office:automatic-styles>
      doc.root.each_element('office:automatic-styles/*') do |e|
        attr = e.attributes.get_attribute('style:name')
        attr && style_names[attr.value] = attr
      end

      # Replace all auto styles in the document's attributes with the
      # prefixed form.
      doc.each_element('//*') do |e|
        e.attributes.each_attribute do |attr|
          if style_names.has_key? attr.value
            e.add_attribute(attr.expanded_name, "#{self.prefix}_#{attr.value}")
          end
        end
      end

      # Create 'documatic/partial/' in zip file
      self.jar.find_entry('documatic/partial') ||
        self.jar.mkdir('documatic/partial')
      
      # Save the prefix in documatic/partial.txt
      self.jar.get_output_stream('documatic/partial/partial.txt') do |f|
        f.write self.prefix
      end

      # Set @styles, & save it in documatic/styles.xml
      @styles = doc.root.elements['office:automatic-styles']
      self.jar.get_output_stream('documatic/partial/styles.xml') do |f|
        f.write @styles.to_s
      end

      # Get body text, erbify it, keep it in @content and save it in
      # documatic/content.erb
      body_text = doc.root.elements['office:body/office:text']
      body_text.elements.delete('text:sequence-decls')
      body_text.elements.delete('office:forms')
      @content_erb = self.erbify( (body_text.elements.to_a.collect do |e|
                                     e.to_s ;
                                   end ).join("\n") )
      self.jar.get_output_stream('documatic/partial/content.erb') do |f|
        f.write @content_erb
      end

    end

    # Partials aren't saved in the same way that templates are: this
    # is a no-op.
    def save ; end
    
    def prefix
      if not @prefix
        if self.jar.find_entry('documatic/partial/partial.txt')
          @prefix = self.jar.read('documatic/partial/partial.txt')
        else
          @prefix = File.basename(self.filename, '.odt').gsub(/[^A-Za-z0-9_]/,
                                                              '_')
        end
      end
      return @prefix
    end

    def content_erb
      if not @content_erb
        if self.jar.find_entry('documatic/partial/content.erb')
          self.jar.read('documatic/partial/content.erb')
        else
          self.compile
        end
      end
      @content_erb
    end

    def styles
      if not @styles
        if self.jar.find_entry('documatic/partial/styles.xml')
          @styles = REXML::Document.new( self.jar.read('documatic/partial/styles.xml') ).root
        else
          self.compile
        end
      end
      @styles
    end
    
  end
end
