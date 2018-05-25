class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  def uppercase_name
    name.upcase
  end
end
