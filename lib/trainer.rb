class Trainer
  attr_accessor :id, :name, :bio,
                :gravatar_email, :twitter_username, :linkedin_url

  def initialize()
    @name = @bio = @gravatar_email = @twitter_username = @linkedin_ur = ''
  end

  def load_from_json(t_json)
    @id = t_json['id'].to_i
    load_str(%i[name bio gravatar_email twitter_username linkedin_url], t_json)
    self
  end
  def load_str(syms, hash)
    syms.each { |field| send("#{field}=", hash[field.to_s]) }
  end

  def gravatar_picture_url
    hash = 'asljasld'
    hash = Digest::MD5.hexdigest(gravatar_email) unless gravatar_email.nil?
    @gravatar_picture = "https://www.gravatar.com/avatar/#{hash}"
  end

end

# "id": 57,
# "name": "Camilo Velasquez",
# "created_at": "2016-08-24T15:59:29.161Z",
# "updated_at": "2021-05-16T21:59:09.577Z",
# "bio": "> Mi enfoque es siempre la mejora continua y la experimentación como base de aprendizaje\r\n\r\n**Camilo Velasquez**\r\nAgile Coach & Trainer \r\nIng. Sistemas, CSM",
# "gravatar_email": "c.cvelasquez@outlook.com",
# "twitter_username": "velkan12",
# "linkedin_url": "https://co.linkedin.com/in/camilovelasquezardila",
# "is_kleerer": true,
# "country_id": 46,
# "tag_name": "TR-CV (Camilo Velasquez)",
# "signature_image": "cv.png",
# "signature_credentials": "Agile Coach & Trainer",
# "average_rating": "4.64",
# "net_promoter_score": null,
# "surveyed_count": 39,
# "promoter_count": null,
# "bio_en": "My approach is always continuous improvement and experimentation as a basis for learning\r\n\r\n**Camilo Velasquez**\r\nAgile Coach & Trainer \r\nIng. Sistemas, CSM"