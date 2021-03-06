class Course < Canvas
  attr_accessor :id, :sis_course_id, :name, :course_code, :account_id, :start_at, :end_at, :enrollments, :course_calendar, :syllabus_body_html, :folders, :assignments, :pages, :discussion_topics
  
  def initialize(id, params)
    @id = id
    attrs = %w(id sis_course_id name course_code account_id start_at
               end_at enrollments course_calendar syllabus_body_html
               folders pages)
    attrs.each { |attr| self.instance_variable_set("@#{attr}", params[attr]) unless attr == "id" }
    
    get_assignments; get_dt #Speed this up
    #get_dt
  end
  
  def pages
    @pages = []
    @api_page_url = "#{@@api_root_url}/courses/#{self.id}/pages"    
    pages_json = self.get_json(@api_page_url)
    pages_json.each { |page_json| @pages << Page.new(page_json) }
    @pages
  end
  
  private
  def get_assignments
    api_course_assignments_url = "#{@@api_root_url}/courses/#{self.id}/assignments"
    @assignments = []
    begin
      assignments_json = self.get_json(api_course_assignments_url)
    rescue RestClient::Unauthorized => e
    else
      assignments_json.each do |assignment|
        @assignments << Assignment.new(assignment["id"], assignment)
      end
      @assignments
    end
  end
  
  private
  def get_dt
    api_course_discussion_topics_url = "#{@@api_root_url}/courses/#{self.id}/discussion_topics"
    dt_json = self.get_json(api_course_discussion_topics_url)
    @discussion_topics = []
    dt_json.each { |dt| @discussion_topics << DiscussionTopic.new(dt['id'], dt) }
    @discussion_topics
  end
  
end

class Section < Canvas
  attr_accessor :id, :name, :sis_section_id, :course_id, :nonxlist_course_id
end

class CanvasModule < Canvas
  attr_accessor :id, :position, :name, :unlock_at, :require_sequential_progress, :prerequisite_module_ids, :state, :completed_at, :module_items
end

class CanvasModuleItem < Canvas
  attr_accessor :id, :position, :title, :indent_level, :type, :html_url, :canvas_api_url, :completion_requirement
end