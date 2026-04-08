json.array! @assets do |asset|
  json.id          asset.id
  json.title       asset.title
  json.description asset.description
  json.file_type   asset.file_type
  json.file_size   asset.file_size

  if asset.files.attached?
    json.url       url_for(asset.files.first)
    json.thumbnail asset.image? ? url_for(asset.files.first.variant(resize_to_limit: [200, 200]).processed) : nil
  else
    json.url       nil
    json.thumbnail nil
  end

  json.created_at asset.created_at
end
