# =============================================================================
# VaultShare Seed Data
# =============================================================================
# Run with: docker compose exec web rails db:seed
# =============================================================================

puts "Cleaning existing data..."
ActivityLog.delete_all
Comment.delete_all
Asset.delete_all
Collection.delete_all
Library.delete_all
User.delete_all

# =============================================================================
# Users
# =============================================================================
puts "Creating users..."

admin = User.create!(
  email: "admin@vaultshare.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)

contributor = User.create!(
  email: "designer@vaultshare.com",
  password: "password123",
  password_confirmation: "password123",
  role: "contributor"
)

viewer = User.create!(
  email: "viewer@vaultshare.com",
  password: "password123",
  password_confirmation: "password123",
  role: "viewer"
)

# =============================================================================
# File helpers — minimal valid binary data for each type
# =============================================================================

# Minimal 1×1 white PNG
MINIMAL_PNG = Base64.decode64(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwADhQGAWjR9awAAAABJRU5ErkJggg=="
)

# Minimal valid PDF
MINIMAL_PDF = <<~PDF
  %PDF-1.4
  1 0 obj<</Type /Catalog /Pages 2 0 R>>endobj
  2 0 obj<</Type /Pages /Kids[3 0 R]/Count 1>>endobj
  3 0 obj<</Type /Page /MediaBox[0 0 612 792]/Parent 2 0 R /Resources<<>>>>endobj
  xref
  0 4
  0000000000 65535 f
  0000000009 00000 n
  0000000058 00000 n
  0000000115 00000 n
  trailer<</Size 4/Root 1 0 R>>
  startxref
  190
  %%EOF
PDF

# Minimal valid WAV (44-byte header + silence)
def minimal_wav
  num_channels    = 1
  sample_rate     = 8000
  bits_per_sample = 8
  num_samples     = 8000  # 1 second of silence
  data_size       = num_samples * num_channels * (bits_per_sample / 8)
  byte_rate       = sample_rate * num_channels * (bits_per_sample / 8)
  block_align     = num_channels * (bits_per_sample / 8)

  header = [
    "RIFF",
    36 + data_size,
    "WAVE",
    "fmt ",
    16,
    1,                # PCM
    num_channels,
    sample_rate,
    byte_rate,
    block_align,
    bits_per_sample,
    "data",
    data_size
  ].pack("A4VA4A4VvvVVvvA4V")

  header + (128.chr * num_samples) # 128 = silence in 8-bit unsigned PCM
end

WAV_DATA = minimal_wav

def attach_png(asset, filename)
  asset.files.attach(
    io:           StringIO.new(MINIMAL_PNG),
    filename:     filename,
    content_type: "image/png"
  )
  asset.update_columns(file_type: "image/png", file_size: MINIMAL_PNG.bytesize)
end

def attach_pdf(asset, filename)
  asset.files.attach(
    io:           StringIO.new(MINIMAL_PDF),
    filename:     filename,
    content_type: "application/pdf"
  )
  asset.update_columns(file_type: "application/pdf", file_size: MINIMAL_PDF.bytesize)
end

def attach_wav(asset, filename)
  asset.files.attach(
    io:           StringIO.new(WAV_DATA),
    filename:     filename,
    content_type: "audio/wav"
  )
  asset.update_columns(file_type: "audio/wav", file_size: WAV_DATA.bytesize)
end

# =============================================================================
# Libraries
# =============================================================================
puts "Creating libraries..."

marketing = Library.create!(user: admin,       name: "Marketing Assets",   visibility: :shared)
product   = Library.create!(user: contributor, name: "Product Design v2",  visibility: :shared)
internal  = Library.create!(user: admin,       name: "Internal Docs",      visibility: :restricted)

# =============================================================================
# Collections
# =============================================================================
puts "Creating collections..."

# Marketing
brand    = marketing.collections.create!(name: "Brand Guidelines")
campaign = marketing.collections.create!(name: "Q2 Campaign")

# Product
screens  = product.collections.create!(name: "UI Screens")
icons    = product.collections.create!(name: "Icon Set")

# Internal
policies = internal.collections.create!(name: "HR Policies")
finance  = internal.collections.create!(name: "Finance Reports")

# =============================================================================
# Assets
# =============================================================================
puts "Creating assets..."

# --- Brand Guidelines ---
logo = brand.assets.create!(title: "VaultShare Logo", description: "Primary brand logo on dark background")
attach_png(logo, "vaultshare_logo.png")

banner = brand.assets.create!(title: "Hero Banner", description: "Website hero section banner — 1920×1080")
attach_png(banner, "hero_banner.png")

style_guide = brand.assets.create!(title: "Style Guide v3", description: "Colors, typography and component specs")
attach_pdf(style_guide, "style_guide_v3.pdf")

# --- Q2 Campaign ---
ad_copy = campaign.assets.create!(title: "Ad Copy Pack", description: "Copywriting drafts for Q2 social ads")
attach_pdf(ad_copy, "ad_copy_q2.pdf")

jingle = campaign.assets.create!(title: "Campaign Jingle", description: "30-second audio jingle for radio")
attach_wav(jingle, "campaign_jingle.wav")

promo_img = campaign.assets.create!(title: "Promo Visual", description: "Primary promotional visual for all channels")
attach_png(promo_img, "promo_visual.png")

# --- UI Screens ---
dashboard_screen = screens.assets.create!(title: "Dashboard Screen", description: "Main dashboard wireframe — light mode")
attach_png(dashboard_screen, "dashboard_screen.png")

onboarding = screens.assets.create!(title: "Onboarding Flow", description: "3-step onboarding mockup")
attach_png(onboarding, "onboarding_flow.png")

# --- Icon Set ---
icon_pack = icons.assets.create!(title: "Core Icons v1", description: "24px SVG icon set — 120 icons")
attach_pdf(icon_pack, "core_icons_v1.pdf")

# --- HR Policies ---
handbook = policies.assets.create!(title: "Employee Handbook 2026", description: "Full HR policy document")
attach_pdf(handbook, "employee_handbook_2026.pdf")

remote_policy = policies.assets.create!(title: "Remote Work Policy", description: "Updated WFH guidelines")
attach_pdf(remote_policy, "remote_work_policy.pdf")

# --- Finance Reports ---
q1_report = finance.assets.create!(title: "Q1 2026 Financial Report", description: "Quarterly P&L and balance sheet")
attach_pdf(q1_report, "q1_2026_financial_report.pdf")

budget = finance.assets.create!(title: "FY2026 Budget", description: "Approved annual budget breakdown")
attach_pdf(budget, "fy2026_budget.pdf")

# =============================================================================
# Share tokens
# =============================================================================
puts "Generating share links..."

logo.generate_share_token!(expires_in: 30.days)
style_guide.generate_share_token!(expires_in: 7.days)
jingle.generate_share_token!(expires_in: 7.days)

# =============================================================================
# Comments
# =============================================================================
puts "Creating comments..."

Comment.create!(user: viewer,      asset: logo,            content: "Love the new logo — clean and professional!")
Comment.create!(user: contributor, asset: logo,            content: "Agreed. Should we add a white variant too?")
Comment.create!(user: admin,       asset: logo,            content: "Already in the pipeline for next sprint.")

Comment.create!(user: admin,       asset: style_guide,     content: "Please review section 3 on typography spacing.")
Comment.create!(user: contributor, asset: style_guide,     content: "Updated — Inter 16px / 1.6 line-height confirmed.")

Comment.create!(user: viewer,      asset: jingle,          content: "The fade-in at 0:08 sounds great!")
Comment.create!(user: admin,       asset: jingle,          content: "Approved for the radio buy. Let's lock it.")

Comment.create!(user: contributor, asset: dashboard_screen, content: "Nav should be collapsible on mobile.")
Comment.create!(user: admin,       asset: dashboard_screen, content: "Logged as a design ticket. Will follow up.")

Comment.create!(user: viewer,      asset: handbook,         content: "Is section 4.2 updated for the new leave policy?")
Comment.create!(user: admin,       asset: handbook,         content: "Yes — effective Jan 1 2026.")

# =============================================================================
# Activity Logs
# =============================================================================
puts "Creating activity logs..."

[logo, banner, style_guide, ad_copy, jingle, promo_img,
 dashboard_screen, onboarding, icon_pack, handbook, remote_policy,
 q1_report, budget].each do |asset|
  ActivityLog.create!(user: admin, asset: asset, action: "upload")
end

ActivityLog.create!(user: viewer,      asset: logo,        action: "download")
ActivityLog.create!(user: contributor, asset: style_guide, action: "download")
ActivityLog.create!(user: viewer,      asset: jingle,      action: "download")
ActivityLog.create!(user: admin,       asset: q1_report,   action: "download")

ActivityLog.create!(user: contributor, asset: logo,            action: "update")
ActivityLog.create!(user: admin,       asset: style_guide,     action: "update")
ActivityLog.create!(user: contributor, asset: dashboard_screen, action: "update")

# =============================================================================
puts ""
puts "=" * 50
puts "  Seed data created successfully!"
puts "=" * 50
puts ""
puts "  Login credentials (password: password123)"
puts ""
puts "  admin@vaultshare.com    — Admin"
puts "  designer@vaultshare.com — Contributor"
puts "  viewer@vaultshare.com   — Viewer"
puts ""
puts "  Libraries : #{Library.count}"
puts "  Collections: #{Collection.count}"
puts "  Assets    : #{Asset.count}"
puts "  Comments  : #{Comment.count}"
puts "  Logs      : #{ActivityLog.count}"
puts "=" * 50
