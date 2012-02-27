class Diesel::App
  include Diesel
  app_name :app_one

  pblock :first, stuff: true do
    required :name do
      matches(/kyle/)
    end

    optional :awesomeness do
      allowed_values %w{high medium low}
    end
  end

  endpoint :this do
    required :id do
      integer
    end

    import_pblock :first
    required :awesomeness do
      allowed_values %w{}
    end
  end

  endpoint :that do
    import_pblock :first
  end

  def self.router
    @_router
  end
end