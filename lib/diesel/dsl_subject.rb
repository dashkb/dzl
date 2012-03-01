class Diesel::DSLSubject
  attr_reader :name, :opts, :router

  def dsl_proxy
    @dsl_proxy || raise("You must set @dsl_proxy in your DSLSubject subclass")
  end
end