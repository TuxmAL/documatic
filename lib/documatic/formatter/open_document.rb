require 'fileutils'
require 'ruport'

module Documatic
  module Formatter

  class OpenDocumentText < Ruport::Formatter
    class << self
      attr_accessor :processor
    end

    self.processor = Documatic::OpenDocumentText::Template
    renders :odt_template, :for => [ Ruport::Controller::Table,
                                     Ruport::Controller::Group,
                                     Ruport::Controller::Grouping ]
    
    def build
      self.class.processor.process_template(:data => data, :options => options)
    end
    alias_method :build_table_body, :build  # for Ruport::Controller::Table
    alias_method :build_group_body, :build  # for Ruport::Controller::Group
    alias_method :build_grouping_body, :build # for Ruport::Controller::Grouping
  end

  class OpenDocumentSpreadsheet < OpenDocumentText
    self.processor = Documatic::OpenDocumentSpreadsheet::Template
    renders :ods_template, :for => [ Ruport::Controller::Table,
                                     Ruport::Controller::Group,
                                     Ruport::Controller::Grouping ]
  end    

  end  # module Formatter
end  # module Documatic
