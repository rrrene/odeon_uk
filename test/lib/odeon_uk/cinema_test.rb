require_relative '../../test_helper'
 
describe OdeonUk::Cinema do

  before { WebMock.disable_net_connect! }

  describe '#all' do
    subject { OdeonUk::Cinema.all }

    before do
      sitemap_body = File.read( File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'sitemap.html') )
      stub_request(:get, 'http://www.odeon.co.uk/fanatic/sitemap/').to_return( status: 200, body: sitemap_body, headers: {} )
    end
 
    it 'returns a list of symbols' do
      subject.must_be_instance_of(Array)
      subject.each do |value|
        value.must_be_instance_of(Hash)
      end
    end

    it 'requests the odeon.co.uk sitemap page' do
      subject
      assert_requested :get, 'http://www.odeon.co.uk/fanatic/sitemap/', times: 1
    end

    it 'returns the correctly sized array' do
      subject.size.must_equal 23
    end
  end
  end

end