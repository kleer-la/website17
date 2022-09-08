class Testimony

  attr_accessor :name, :last_name, :email, :phone, :event_id, :created_at,
                :message

  def initialize
    @name = @last_name = @email = @phone = @message = ""
    @event_id = 0
  end

  def load_from_json(json)
    @name = json["fname"]
    @last_name = json["lname"]
    @email = json["email"]
    @phone = json["phone"]
    @event_id = json["event_id"]
    @event_id = Date.parse(json["created_at"])
    @message = json["testimony"]
  end
end
