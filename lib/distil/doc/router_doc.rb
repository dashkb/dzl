module Diesel::RouterDoc

  def to_md(app_name=nil)
    index_template = File.read("./lib/diesel/doc/templates/index.erb")

    ERB.new(index_template, nil, "-%").result(binding)
  end
end