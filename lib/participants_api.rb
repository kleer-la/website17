require 'net/http'
require './lib/keventer_connector'

class ParticipantsApi
  def self.createNull
    ParticipantsApi.new NullApi.new
  end

  def self.createKeventer
    ParticipantsApi.new KeventerApi.new
  end

  def initialize(api)
    @api = api
  end

  def interest(event_type_id, email, notes)
    @api.interest(event_type_id, email, notes)
  end
end

class NullApi
  def initialize(status = '200')
    @status = status
  end

  def interest(_event_type_id, _email, _notes)
    @status
  end
end

class KeventerApi
  def interest(_event_type_id, email, notes)
    uri = URI(KeventerConnector.interest_url)
    # res = Net::HTTP.post_form(uri, 'event_type_id' => '1', 'email' => 'a@b.com', 'notes'=> 'More Info')
    res = Net::HTTP.post_form(uri, 'event_type_id' => '1245', 'email' => email, 'notes' => notes,
                                   'firstname' => email,
                                   'lastname' => '-',
                                   'country_iso' => 'AR')
    res.code
  end
end
