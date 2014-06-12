class Track < ActiveRecord::Base
  has_many :scrobbles
end
