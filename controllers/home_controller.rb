require './lib/clients'



def first_x_courses(courses, quantity)
  courses
    .select {|e| e.event_type.lang == session[:locale]}
    .uniq { |e| e.event_type.id}
    .first(quantity)
    .map.with_index { |course, index|
      is_open = (course.date.to_s != '')
      date = is_open ? format_date_range(course.date, course.finish_date, 'es') : t('home2022.home_courses.no_date')
      {
        title: course.event_type.name, duration: course.event_type.duration, subtitle: course.event_type.subtitle,
        cover: course.event_type.cover, uri_path: course.event_type.uri_path, open: false,date: date, url: course.event_type.uri_path,
        country: 'OL', certified: (2 if course.event_type.is_sa_cert).to_i +
                                  (1 if course.event_type.is_kleer_cert).to_i,
        active: index == 0
      }
    }
end


get '/' do
  @meta_tags.set!  title: t('meta_tag.home.title'),
                   description: t('meta_tag.home.description'),
                   canonical:  "#{session[:locale]}/"


  @clients =  client_list
  @coming_courses = if session[:locale] == 'es'
                      first_three = first_x_courses(coming_courses, 3)
                      one =AcademyCourses.new.load.select(session[:locale], 1)
                        .map { |e| e.transform_keys(&:to_sym)  }
                      if one == []
                        first_three
                      else
                        one[0][:categories] = nil
                        one[0][:date] = 'Academia'

                        first_three << one[0]
                      end
                    else
                      first_x_courses( KeventerReader.instance.catalog_events(),  3)
                    end
  erb :'home/index', layout: :'layout/layout2022'
end


not_found do
  @meta_tags.set! title: t('page_not_found')

  erb :'home/error_404', layout: :'layout/layout2022'
end
