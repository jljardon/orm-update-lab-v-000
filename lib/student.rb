require_relative '../config/environment.rb'

class Student
   #  with DB[:conn]
   attr_accessor :name, :grade, :id

   def initialize(id = nil, name, grade)
      @name = name
      @grade = grade
      @id = id
   end

   def save
      if id
         update
      else
         sql = <<-SQL
         INSERT INTO students (name, grade)
         VALUES (?, ?)
         SQL

         DB[:conn].execute(sql, name, grade)
         @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
      end
   end

   def update
      sql = 'UPDATE students SET name = ?, grade = ? WHERE id = ?'
      DB[:conn].execute(sql, name, grade, id)
   end

   def self.create(name, grade)
      # sql = <<-SQL
      # INSERT INTO students (name, grade)
      # VALUES (?, ?)
      # SQL
      #
      # DB[:conn].execute(sql, name, grade)

      student = Student.new(name, grade)
      student.save
   end

   def self.new_from_db(row)
      Student.new(row[0], row[1], row[2])
   end

   def self.find_by_name(name)
      sql = <<-SQL
      SELECT * from students
      WHERE name = ?
      SQL
      Student.new_from_db(DB[:conn].execute(sql, name).flatten)
   end

   def self.create_table
      sql = <<-SQL
      CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
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
end
