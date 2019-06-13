require_relative "../config/environment.rb"
require "pry"

def student_from_row(row)
  new_student = Student.new
  new_student.init(row[0], row[1], row[2])
  new_student
end

class Student
  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def is_in_db?
    if @id == nil
      return false
    end
    sql =<<-SQL
      SELECT COUNT(*) FROM students WHERE students.id == ?
    SQL
    result = DB[:conn].execute(sql, @id)
    return result[0][0]
  end

  def update
    sql =<<-SQL
      UPDATE students SET name = ?, grade = ? WHERE students.id == ?
    SQL
    DB[:conn].execute(sql, [@name, @grade, @id])
  end

  def save
    if is_in_db?
      update
    else
      sql =<<-SQL
        INSERT INTO students (name, grade) VALUES(?,?)
      SQL

    DB[:conn].execute(sql, [name, grade])
    row_id = DB[:conn].last_insert_row_id
    @id = row_id
    end
  end

  def self.create(name, grade)
    new_student = Student.new(nil, name, grade)
    new_student.save
  end

  def self.find_by_name(name)
    sql =<<-SQL
      SELECT * FROM students WHERE students.name = ?
    SQL

    result = DB[:conn].execute(sql, name).flatten

    Student.new(result[0], result[1], result[2])
  end
end
