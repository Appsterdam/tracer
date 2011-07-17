module GeoInitializer
  def self.registered(app)
    ::Geokit::Geocoders::google = "ABQIAAAAhAvAaFz2L66Hu8_rUB5MthRIgq1sJJBZV82nvGWTFIV9S3cs1BSwT1_2KYAXSRao7NdPjJPbPd7b5A"
  end
end
