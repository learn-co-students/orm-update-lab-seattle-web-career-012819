require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
          id INTEGER PRIMARY KEY
        , name TEXT
        , grade TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
    if self.id
      self.update
    else
      DB[:conn].execute(sql, self.name, self.grade)

      self.id = DB[:conn].execute("select * from students order by id asc limit 1")[0][0]
    end

    self
  end

  def self.create(id = nil, name, grade)
    new_student = Student.new(id, name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    Student.create(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students s
      WHERE s.name = ?
      SQL

    row = DB[:conn].execute(sql, name).flatten
    Student.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET
        name = ?
      , grade = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
