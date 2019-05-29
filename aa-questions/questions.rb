require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    return nil if user.empty?

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    questions = QuestionsDBConnection.instance.execute(<<-SQL,self.id)  SELECT
        *
      FROM
        questions
      JOIN 
        question_follows
        ON 

    SQL

  end

end

class Question
  attr_accessor :id, :title, :body, :user_id

  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT  
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if question.empty?

    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT 
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    return nil if questions.empty?

    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    user = QuestionsDBConnection.instance.execute(<<-SQL,self.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
      SQL

      User.new(user.first)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end
 
end


class QuestionFollow
  attr_accessor :id, :question_id, :user_id

  def self.followers_for_question_id(question_id)
    followers = QuestionsDBConnection.instance.execute(<<-SQL,question_id)
    SELECT
      * 
    FROM
      users
    JOIN 
      question_follows
      ON users.id = question_follows.user_id
    WHERE
      question_follows.question_id = ?
    SQL

    followers.map { |follower| User.new(follower) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end

class Reply
  attr_accessor :id, :question_id, :body, :parent_id, :user_id
 
  def self.find_by_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT  
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if reply.empty?

    Reply.new(reply.first)

  end


  def self.find_by_user_id(user_id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      replies.user_id = ?
    SQL

    return nil if replies.empty?

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      replies.question_id = ?
    SQL

    return nil if replies.empty?

    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @body = options['body']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
  end

  def author
    user = QuestionsDBConnection.instance.execute(<<-SQL, self.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    User.new(user.first)

  end

  def question
    quest = QuestionsDBConnection.instance.execute(<<-SQL, self.question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    Question.new(quest.first)
  end

  def parent_reply
    parent = QuestionsDBConnection.instance.execute(<<-SQL, self.parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL
    return nil if parent.empty?

    Reply.new(parent.first)
  end

  def child_replies
    child = QuestionsDBConnection.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_id = ?
    SQL
    return nil if child.empty?

    Reply.new(child.first)
  end
end

class QuestionLikes
  attr_accessor :user_id, :question_id

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end