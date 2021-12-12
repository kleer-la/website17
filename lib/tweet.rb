class Tweet
  def initialize(user_id, text)
    @user_id = user_id
    @text = text
  end

  attr_reader :user_id, :text
end
