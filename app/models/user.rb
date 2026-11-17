class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # admin: hace todo en el backend. score_editor: solo edita puntos y multiplicadores.
  enum :role, { admin: "admin", score_editor: "score_editor" }, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }
end
