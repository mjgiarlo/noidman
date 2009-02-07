class Identifier < ActiveRecord::Base
  belongs_to :user
  belongs_to :contract
  belongs_to :authority

  validates_presence_of :ark, :url, :user_id, :authority_id
  validates_uniqueness_of :ark, :url

  def validate
    begin
      uri = URI.parse(url)
    rescue URI::InvalidURIError
      errors.add(:url, 'Invalid URL!')
    end
  end
end
