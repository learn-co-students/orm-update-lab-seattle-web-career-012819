require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade
  attr_reader :id

  @@all = []

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade

    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name STRING,
        grade STRING
      );
    SQL
    DB[:conn].execute(sql)
  end

  # removes students table
  # .drop_table -> []
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id.nil?
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
  end

  def update
    sql = <<~SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id, name, grade = row
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = <<~SQL
      SELECT * FROM students WHERE students.name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def self.all
    @@all
  end

end
