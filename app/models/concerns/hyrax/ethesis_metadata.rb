module Hyrax
  # An optional model mixin to define some simple properties. This must be mixed
  # after all other properties are defined because no other properties will
  # be defined once  accepts_nested_attributes_for is called
  module EthesisMetadata
    extend ActiveSupport::Concern

    included do
      property :degree,      predicate: RDF::URI.intern('http://vivoweb.org/ontology/core#AcademicDegree'), multiple: false
      property :department,  predicate: RDF::URI.intern('http://vivoweb.org/ontology/core#AcademicDepartment')
      property :institution, predicate: RDF::Vocab::MARCRelators.dgg
      property :orcid_id,    predicate: RDF::URI.intern('http://vivoweb.org/ontology/core#orcidId')
      property :school,      predicate: RDF::URI.intern('http://vivoweb.org/ontology/core#School')
      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
      

      #id_blank = proc { |attributes| attributes[:id].blank? }

      #class_attribute :controlled_properties
      #self.controlled_properties = [:based_near]
      #accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true
    end
  end
end
