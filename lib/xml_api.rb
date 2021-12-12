class XmlAPI
    attr_accessor :xml_doc
    def initialize(file_uri)
        begin      
        xml= LibXML::XML::Parser.file(file_uri)
        @xml_doc= xml.parse
        rescue LibXML::XML::Error
        nil
        end
    end
end
