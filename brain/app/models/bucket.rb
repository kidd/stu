class Bucket < ActiveRecord::Base
  serialize :tracks, Array
end
