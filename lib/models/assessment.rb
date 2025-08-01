require './lib/json_api'
require './lib/services/keventer_api'

class Assessment
  @next_null = false
  @assessment_null = nil

  # Mock a null assessment for testing
  def self.create_one_null(data, locale, opt = {})
    @next_null = opt[:next_null] == true
    @assessment_null = Assessment.new(data, locale || 'en')  # Default to English
  end

  def self.create_one_keventer(id, locale = 'en')
    if @next_null
      @next_null = false
      return @assessment_null
    end

    api_resp = JsonAPI.new(KeventerAPI.assessment_url(id))
    raise AssessmentNotFoundError.new(id) unless api_resp.ok?

    Assessment.new(api_resp.doc, locale)
  end

  attr_accessor :id, :title, :description, :rule_based, :question_groups, :questions

  def initialize(doc, _lang= '')  # Remove lang parameter since we're not localizing
    @id = doc.is_a?(Hash) && doc['id'] ? doc['id'] : nil
    @title = doc.is_a?(Hash) && doc['title'] ? doc['title'] : ''
    @description = doc.is_a?(Hash) && doc['description'] ? doc['description'] : ''
    @rule_based = doc.is_a?(Hash) && doc['rule_based'] ? doc['rule_based'] : false

    init_questions_and_groups(doc)
  end

  private

  def init_questions_and_groups(doc)
    # Ensure doc is a Hash and check for question_groups/questions
    if doc.is_a?(Hash)
      @question_groups = (doc['question_groups'] || []).map { |group| QuestionGroup.new(group) }
      @questions = (doc['questions'] || []).map { |question| Question.new(question) }
    else
      @question_groups = []
      @questions = []
    end
  end

  # Nested class for QuestionGroup
  class QuestionGroup
    attr_accessor :id, :name, :position, :questions

    def initialize(doc)
      @id = doc.is_a?(Hash) && doc['id'] ? doc['id'] : nil
      @name = doc.is_a?(Hash) && doc['name'] ? doc['name'] : ''
      @position = doc.is_a?(Hash) && doc['position'] ? doc['position'] : 1  # Default to 1
      @questions = (doc.is_a?(Hash) && doc['questions'] || []).map { |q| Question.new(q) }
    end
  end

  # Nested class for Question
  class Question
    attr_accessor :id, :name, :description, :position, :question_type, :answers

    def initialize(doc)
      @id = doc.is_a?(Hash) && doc['id'] ? doc['id'] : nil
      @name = doc.is_a?(Hash) && doc['name'] ? doc['name'] : ''
      @description = doc.is_a?(Hash) && doc['description'] ? doc['description'] : ''
      @position = doc.is_a?(Hash) && doc['position'] ? doc['position'] : 1  # Default to 1
      @question_type = doc.is_a?(Hash) && doc['question_type'] ? doc['question_type'] : 'linear_scale'  # Default
      @answers = (doc.is_a?(Hash) && doc['answers'] || []).map { |a| Answer.new(a) }
    end
  end

  # Nested class for Answer
  class Answer
    attr_accessor :id, :text, :position

    def initialize(doc)
      @id = doc.is_a?(Hash) && doc['id'] ? doc['id'] : nil
      @text = doc.is_a?(Hash) && doc['text'] ? doc['text'] : ''
      @position = doc.is_a?(Hash) && doc['position'] ? doc['position'] : 1  # Default to 1
    end
  end
end

class AssessmentNotFoundError < StandardError
  def initialize(id)
    super("Assessment with ID '#{id}' not found")
  end
end