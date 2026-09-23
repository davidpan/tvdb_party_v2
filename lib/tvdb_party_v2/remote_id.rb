module TvdbPartyV2
  # v4 remote id 辅助:统一处理 imdb id 与 remote_id 的互转
  module RemoteId
    module_function

    # 从 remoteIds 数组中提取 imdb id(如 "tt1796960")
    def imdb_from(remote_ids)
      Array(remote_ids).each do |r|
        next unless r.is_a?(Hash)
        return r["id"] if r["sourceName"].to_s.casecmp?("imdb") || r["id"].to_s.start_with?("tt")
      end
      nil
    end

    # imdb id 转 v4 remote_id 查询格式(如 "imdb-tt1796960")
    def for_imdb(imdb_id)
      id = imdb_id.to_s
      return id if id =~ /\Aimdb-/i
      id.start_with?('tt') ? "imdb-#{id}" : "imdb-tt#{id}"
    end
  end
end
