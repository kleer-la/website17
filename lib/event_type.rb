require './lib/json_api'

require './lib/keventer_helper'
require './lib/event'
require './lib/testimony'
require './lib/models/coupon'
require './lib/image_url_helper'

class EventType
  def self.create_keventer_json(id)
    json_api = if defined? @@json_api
                 @@json_api
               else
                 JsonAPI.new(KeventerAPI.event_type_url(id))
               end
    et = EventType.new(json_api.doc) unless json_api.doc.nil?
    et unless et&.id.nil?
  end

  def self.null_json_api(null_api)
    @@json_api = null_api
  end

  attr_accessor :id, :duration, :lang, :cover, :name, :subtitle, :description, :learnings, :takeaways,
                :goal, :recipients, :program, :faq, :external_site_url, :elevator_pitch, :include_in_catalog,
                :deleted, :noindex, :categories, :slug, :canonical_slug, :is_kleer_cert, :is_sa_cert,
                :public_editions, :side_image, :brochure, :is_new_version, :testimonies, :extra_script, :platform,
                :coupons, :recommended

  def initialize(hash_provider = nil)
    @hash_provider = hash_provider
    @id = nil
    @testimonies = []
    @coupons = []
    load_complete_event(hash_provider)
    init_recommended(hash_provider)
  end

  # json provider
  def load_complete_event(hash_event)
    return if hash_event.nil? || ['id'].nil?

    @id =  hash_event['id'].nil? ? hash_event['event_type_id'].to_i : hash_event['id'].to_i
    @duration = hash_event['duration'].to_i
    @is_kleer_cert = to_boolean(hash_event['is_kleer_certification'])
    @is_sa_cert = to_boolean(hash_event['csd_eligible'])
    @is_new_version = to_boolean(hash_event['new_version'])
    @deleted = to_boolean(hash_event['deleted'])
    @noindex = to_boolean(hash_event['noindex'])
    @extra_script = hash_event['extra_script'] || nil
    @platform = hash_event['platform'] || nil

    @categories = hash_event['categories'].map { |e| e['name'] } unless hash_event['categories'].nil?

    load_testimonies(hash_event['testimonies'])
    load_coupons(hash_event['coupons'])

    %i[name subtitle description learnings takeaways cover
       goal recipients program faq slug canonical_slug lang
       external_site_url elevator_pitch include_in_catalog
       side_image brochure deleted].each { |field| send("#{field}=", hash_event[field.to_s]) }

    @public_editions = load_public_editions(hash_event['next_events'])
  end

  def load_public_editions(next_events)
    return [] if next_events.nil?

    next_events.reduce([]) do |events, ev_json|
      load_coupons(ev_json['coupons']) if ev_json['coupons']
      events << Event.new(self).load_from_json(ev_json)
    end
  end

  def load_testimonies(plane_testimonies)
    return if plane_testimonies.nil?

    plane_testimonies.each do |testimony|
      # TODO: test event type with testimony
      new_testimony = Testimony.new
      new_testimony.load_from_json(testimony)

      @testimonies.push(new_testimony)
    end
  end

  def load_coupons(coupons)
    return if coupons.nil?

    coupons.each do |coupon|
      new_coupon = Coupon.new(coupon['code'], coupon['percent_off'], coupon['icon'])
      @coupons.push(new_coupon)
    end
  end

  def init_recommended(doc)
    @recommended = Recommended.create_list(doc['recommended'])
  end

  def uri_path
    partial = @lang == 'en' ? 'courses' : 'cursos'
    "/#{@lang}/#{partial}/#{@slug}"
  end

  def canonical_url
    partial = @lang == 'en' ? 'courses' : 'cursos'
    "/#{partial}/#{@canonical_slug}" if @canonical_slug.to_s != ''
  end

  def redirect_to(event_type_id_with_name)
    return @external_site_url   if @external_site_url.to_s != ''            # explicit redirect
    return ''                   if @deleted && @canonical_slug == @slug     # dont know where to redirect
    return ''                   if @deleted && @canonical_slug.to_s == ''   # dont know where to redirect
    return canonical_url   if @deleted && @canonical_slug.to_s != ''   # redirect to canonical
    return uri_path        if event_type_id_with_name != @slug         # redirect to itself

    nil # dont redirect
  end

  def cover
    ImageUrlHelper.replace_s3_with_cdn(@cover)
  end

  def side_image
    ImageUrlHelper.replace_s3_with_cdn(@side_image)
  end

  def brochure
    ImageUrlHelper.replace_s3_with_cdn(@brochure)
  end
end
