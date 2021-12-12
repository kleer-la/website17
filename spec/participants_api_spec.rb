require './lib/participants_api'

describe ParticipantsApi do
  it 'a new participant' do
    participants_api = ParticipantsApi.createNull
    @result = participants_api.interest(1, 'j@b.com', 'More info')
    expect(@result).to eq '200'
  end
  it 'a new participant / keventer' do
    participants_api = ParticipantsApi.createKeventer
    @result = participants_api.interest(1, 'j@b.com', 'More info')
    expect(@result).to eq '204'
  end
end
