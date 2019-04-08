class MigrationHelper

  # Get the UUID
  def self.get_uuid_from_path(path)
    path.slice(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
  end

  # Get the Filepath hash
  def self.create_filepath_hash(filename, hash)
    File.open(filename) do |file|
      file.each do |line|
        value = line.strip
        key = get_uuid_from_path(value)
        if !key.blank?
          hash[key] = value
        end
      end
    end
  end

  # Download the file from a give url

  def self.download_file(url, dest)

    dest
  end
  # Get the collection_uuids
  def self.get_collection_uuids(collection_ids_file)
    collection_uuids = Array.new
    File.open(collection_ids_file) do |file|
      file.each do |line|
        if !line.blank? && !get_uuid_from_path(line.strip).blank?
          collection_uuids.append(get_uuid_from_path(line.strip))
        end
      end
    end

    collection_uuids
  end
end
