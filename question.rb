require 'sqlite3'
require 'singleton'
require_relative 'modelbase.rb'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class Question < ModelBase
  attr_accessor :title, :body, :user_id

  TABLE = 'questions'

  def self.find_by_author_id(author_id)
    QuestionsDB.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL
  end

  def self.most_followed(n)
    Follow.most_followed_questions(n)
  end

  def self.most_liked(n)
    Like.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    QuestionsDB.instance.execute(<<-SQL, @user_id)
    SELECT
      DISTINCT users.fname, users.lname
    FROM
      users
    JOIN
      questions ON questions.user_id = users.id
    WHERE
      users.id = ?
    SQL
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    Follow.followers_for_question_id(@id)
  end

  def likers
    Like.likers_for_question_id(@id)
  end

  def num_likes
    Like.num_likes_for_question_id(@id)
  end

end
