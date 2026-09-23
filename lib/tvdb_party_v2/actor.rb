module TvdbPartyV2
  class Actor
    attr_accessor :id, :name, :role, :image, :sortorder

    # v4 的演员信息来自 series extended 的 characters(人物记录)
    def initialize(options = {})
      @id = options["peopleId"] || options["id"]
      @name = options["personName"]
      @role = options["name"] if options["name"]
      @image = options["personImgURL"] if options["personImgURL"]
      @sortorder = options["sort"] if options["sort"]
    end

    def image_url
      return nil unless @image
      @image.start_with?('http') ? @image : "https://www.thetvdb.com/banners/" + @image
    end

  end
end
