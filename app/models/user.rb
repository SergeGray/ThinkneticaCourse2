class User < ApplicationRecord
  has_many :attempts, dependent: :destroy
  has_many :tests, through: :attempts
  has_many :created_tests, class_name: "Test",
                           foreign_key: "author_id",
                           dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true

  def started_by_level(level)
    tests.where(level: level)
  end
end
