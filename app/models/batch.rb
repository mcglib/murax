class Batch < ApplicationRecord
  belongs_to :user
  has_many :import_log
end
