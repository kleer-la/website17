class Testimony

  attr_accessor :name, :last_name, :email, :phone, :event_id, :created_at,
                :message, :linkedin_url, :photo_url

  def initialize
    @name = @last_name = @email = @phone = @message = @photo_url = @linkedin_url = ""
    @event_id = 0
  end

  def load_from_json(json)
    @name = json["fname"]
    @last_name = json["lname"]
    @email = json["email"]
    @phone = json["phone"]
    @message = json["testimony"]
    @linkedin_url = json["profile_url"]
    @photo_url = json["photo_url"]
  end
end
