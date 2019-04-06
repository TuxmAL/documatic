require_relative 'documatic/component'
require_relative 'documatic/version'
require_relative 'documatic/open_document_text/helper'
require_relative 'documatic/open_document_text/component'
require_relative 'documatic/open_document_text/template'
require_relative 'documatic/open_document_text/partial'
require_relative 'documatic/open_document_spreadsheet/helper'
require_relative 'documatic/open_document_spreadsheet/component'
require_relative 'documatic/open_document_spreadsheet/template'

# The module "Documatic" is the namespace for the other modules and
# classes in this project.  It also contains some convenience methods.
module Documatic
  class << self

    # Short-cut method for including a helper in
    # Documatic::OpenDocumentText::Component (the ERb processor).
    # This is the 'old' method that pre-dates the spreadsheet
    # component -- that's why it only adds the helper to the text
    # component.
    def add_helper(helper_module)
      Documatic::OpenDocumentText::Component.send(:include, helper_module)
    end

    # Short-cut method for including a helper in
    # Documatic::OpenDocumentText::Component.
    def text_helper(helper_module)
      add_helper helper_module
    end

    # Short-cut method for including a helper in
    # Documatic::OpenDocumentSpreadsheet::Component.
    def spreadsheet_helper(helper_module)
      Documatic::OpenDocumentSpreadsheet::Component.send(:include,
                                                         helper_module)
    end

  end  # class << self
end

# Force REXML to use double-quotes (consistent with OOo).
REXML::Attribute.class_eval do
  def to_string
    %Q[#@expanded_name="#{to_s().gsub(/"/, '&quot;')}"]
  end
end
