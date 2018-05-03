module TvdbPartyV2
  class Actor
    attr_accessor :id, :name, :role, :image, :sortorder

    def initialize(options = {})
      @id = options["id"]
      @name = options["name"]
      @role = options["role"] if options["role"]
      @image = options["image"] if options["image"]
      @sortorder = options["sortOrder"] if options["sortOrder"]
    end

    def image_url
      return nil unless @image
      "http://www.thetvdb.com/banners/" + @image
    end

  end
end
