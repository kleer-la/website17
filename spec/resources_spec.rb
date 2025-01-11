require './lib/models/resources'

describe Resource do
  context "when creating from keventer" do
    it "should handle accented characters in slug" do
      # Setup
      accented_slug = "liderazgo-ágil"
      expected_sanitized_slug = "liderazgo-agil"
      
      # Mock the JsonAPI to verify the sanitized URL is being used
      json_api_mock = double("JsonAPI")
      expect(JsonAPI).to receive(:new)
                    .with(include(expected_sanitized_slug))
                    .and_return(json_api_mock)
      allow(json_api_mock).to receive(:ok?).and_return(true)
      allow(json_api_mock).to receive(:doc).and_return({
        'slug' => accented_slug,
        'lang' => 'es'
      })

      # Test
      resource = Resource.create_one_keventer(accented_slug)
      expect(resource).not_to be_nil
    end

    it "should raise ResourceNotFoundError for invalid slugs" do
      invalid_slug = "non-existent-resource"
      
      json_api_mock = double("JsonAPI")
      expect(JsonAPI).to receive(:new).and_return(json_api_mock)
      allow(json_api_mock).to receive(:ok?).and_return(false)

      expect {
        Resource.create_one_keventer(invalid_slug)
      }.to raise_error(ResourceNotFoundError)
    end

    it "should handle null resource when next_null is true" do
      # Setup
      slug = "test-resource"
      Resource.create_one_null({ 'slug' => slug }, 'es', next_null: true)

      # Test
      resource = Resource.create_one_keventer(slug)
      expect(resource.slug).to eq(slug)
    end
  end
end
