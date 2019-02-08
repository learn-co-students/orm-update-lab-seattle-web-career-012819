require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_accessor :name, :grade, :id

  def initialize(name,grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table

    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name STRING,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table

    sql = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name,grade)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql,self.name,self.grade)

      return_array = DB[:conn].execute("SELECT * FROM students")
      @id = return_array[0][0]
    end
  end

  def self.create(name,grade)
    new_student = Student.new(name,grade)

    sql = <<-SQL
    INSERT INTO students (name,grade)
    VALUES (?,?)
    SQL

    DB[:conn].execute(sql,new_student.name,new_student.grade)
  end

  def self.new_from_db(row)
    student = self.new(row[1],row[2])
    student.id = row[0]
    student
  end


  def self.find_by_name(given_name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    SQL

    DB[:conn].execute(sql,given_name).map {|row| self.new_from_db(row)}.first
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    SQL

    DB[:conn].execute(sql,self.name,self.grade)
  end
end
