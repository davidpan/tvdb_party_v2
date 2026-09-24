module TvdbPartyV2
  # v4 remote id helpers: imdb id <-> remote_id conversion
  module RemoteId
    module_function

    # Extract the imdb id (e.g. "tt1796960") from a remoteIds array
    def imdb_from(remote_ids)
      Array(remote_ids).each do |r|
        next unless r.is_a?(Hash)
        return r["id"] if r["sourceName"].to_s.casecmp?("imdb") || r["id"].to_s.start_with?("tt")
      end
      nil
    end

    # Convert an imdb id to the v4 remote_id query format (e.g. "imdb-tt1796960")
    def for_imdb(imdb_id)
      id = imdb_id.to_s
      return id if id =~ /\Aimdb-/i
      id.start_with?('tt') ? "imdb-#{id}" : "imdb-tt#{id}"
    end
  end
end
