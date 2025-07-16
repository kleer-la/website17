require './lib/clients'
require './lib/models/page'

def first_x_courses(courses, quantity)
  return [] if courses.nil?

  courses
    .select { |e| e.event_type.lang == session[:locale] }
    .uniq { |e| e.event_type.id }
    .first(quantity)
    .map.with_index do |course, index|
      is_open = (course.date.to_s != '')
      date = is_open ? format_date_range(course.date, course.finish_date, 'es') : t('home.home_courses.no_date')
      {
        title: course.event_type.name, duration: course.event_type.duration, subtitle: course.event_type.subtitle,
        cover: course.event_type.cover, uri_path: course.event_type.uri_path, open: false, date: date, url: course.event_type.uri_path,
        country: 'OL', certified: (2 if course.event_type.is_sa_cert).to_i +
          (1 if course.event_type.is_kleer_cert).to_i,
        active: index.zero?
      }
    end
end

get '/home' do
  new_home
end

get '/' do
  page = Page.load_from_keventer(session[:locale], nil)
  @meta_tags.set!  title: page.seo_title || t('meta_tag.home.title'),
                   description: page.seo_description || t('meta_tag.home.description'),
                   canonical: page.canonical || t('meta_tag.home.canonical')

  @meta_tags.set! image: page.cover unless page.cover.nil? || page.cover.empty?

  @page = page
  @clients = client_list

  @areas = (ServiceAreaV3.try_create_list_keventer + ServiceAreaV3.try_create_list_keventer(programs: true)).
          filter { |a| a.lang == session[:locale] }

  @events = Event.create_keventer_json(
    cache_key: "home_events_#{session[:locale]}"
  ).first(4)

  erb :'home/index2', layout: :'layout/layout2022'
end

not_found do
  @meta_tags.set! title: t('page_not_found')

  erb :'home/error_404', layout: :'layout/layout2022'
end

error 500 do
  @meta_tags.set! title: t('internal_error.title')

  erb :'layout/error_500', layout: :'layout/layout2022'
end
