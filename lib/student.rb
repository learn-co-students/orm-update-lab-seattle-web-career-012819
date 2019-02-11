require_relative "../config/environment.rb"
require 'pry'
class Student
attr_accessor :id, :name, :grade

def initialize(id = nil, name, grade)
  @id = id
  @name = name
  @grade = grade

end

def self.create_table
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students (
  id PRIMARY KEY,
  name TEXT,
  grade INTEGER)
  ;
  SQL

  DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
  DROP TABLE IF EXISTS students
  SQL
  DB[:conn].execute(sql)
end

def save
  if self.id
    self.update
  else
  sql = <<-SQL
  INSERT INTO students (name, grade) 
  VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.grade)
  @id = DB[:conn].execute("SELECT id FROM students DESC LIMIT 1")[0][0]
  end
end

def update
  sql = <<-SQL
  UPDATE students
  SET name = ?, grade = ?
  WHERE id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.grade, self.id)
end

def self.create(name, grade)
  kid = self.new(name, grade)
  kid.save
end

def self.new_from_db(arr)
  self.new(arr[0], arr[1], arr[2])
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM students
  WHERE name IS ?
  SQL
  arr  = DB[:conn].execute(sql, name).flatten!
  Student.new(arr[0], arr[1], arr[2])
end

end #of class