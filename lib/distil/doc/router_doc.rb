module Distil::RouterDoc

  def to_docs
    app_name = app.name.split('::').last
    
    root = app.root || "."

    `mkdir -p #{root}/distil_docs/#{app_name}/`

    home = File.new("./distil_docs/#{app_name}/Home.md", "w")
    home.write(to_md(app_name, root))
    home.close

    endpoints.each do |endpoint|
      endpoint_page = File.new("#{root}/distil_docs/#{app_name}/#{endpoint.doc_file_name}.md", "w")
      endpoint_page.write(endpoint.to_md)
      endpoint_page.close
    end
  end

  def to_md(app_name=nil, root=".")
    home_template = File.read("#{root}/lib/distil/doc/templates/home.erb")

    ERB.new(home_template, nil, "-%").result(binding)
  end
end