require 'sqlite3'

require_relative '../lib/student' unless defined?(STUDENT_RB)

DB = {:conn => SQLite3::Database.new("db/students.db")}