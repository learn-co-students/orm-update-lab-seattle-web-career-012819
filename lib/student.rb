require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade)
    @id = nil
    @name = name
    @grade = grade
  end

  def self.create_table()
    sql = <<-SQL
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table()
    sql = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?,?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end

  end

  def self.create(name, grade)
    new_student =  Student.new(name,grade)
    new_student.save

  end

  def self.new_from_db(row)
    new_student =  Student.new(row[1],row[2])
    new_student.id = row[0]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?;
    SQL

    rows = DB[:conn].execute(sql, name)
    new_from_db(rows[0])
  end

  def update()
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
