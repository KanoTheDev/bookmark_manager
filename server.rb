env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, "postgres://localhost/bokmark_manager_#{env}")

require './lib/link'

DataMapper.finalize
DataMapper.auto_upgrade!