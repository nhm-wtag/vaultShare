class Asset < ApplicationRecord
  belongs_to :collection
  has_many_attached :files
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  validates :title, presence: true

  after_create_commit :sync_file_metadata

  def image?
    file_type&.start_with?("image/")
  end

  def audio?
    file_type&.start_with?("audio/")
  end

  def pdf?
    file_type == "application/pdf"
  end

  def formatted_size
    return "—" unless file_size
    if file_size >= 1.megabyte
      "#{(file_size.to_f / 1.megabyte).round(1)} MB"
    else
      "#{(file_size.to_f / 1.kilobyte).round(1)} KB"
    end
  end

  def generate_share_token!(expires_in: 7.days)
    update!(
      share_token: SecureRandom.urlsafe_base64(24),
      share_token_expires_at: expires_in.from_now
    )
  end

  def revoke_share_token!
    update!(share_token: nil, share_token_expires_at: nil)
  end

  def share_link_active?
    share_token.present? && share_token_expires_at&.future?
  end

  private

  def sync_file_metadata
    return unless files.attached?
    update_columns(
      file_type: files.first.content_type,
      file_size: files.first.byte_size
    )
  end
end
