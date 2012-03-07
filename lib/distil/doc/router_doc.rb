module Diesel::RouterDoc

  def to_docs
    app_name = app.name.split('::').last
    
    root = app.root || "."

    `mkdir -p #{root}/diesel_docs/#{app_name}/`

    home = File.new("./diesel_docs/#{app_name}/Home.md", "w")
    home.write(to_md(app_name, root))
    home.close

    endpoints.each do |endpoint|
      endpoint_page = File.new("#{root}/diesel_docs/#{app_name}/#{endpoint.doc_file_name}.md", "w")
      endpoint_page.write(endpoint.to_md)
      endpoint_page.close
    end
  end

  def to_md(app_name=nil, root=".")
    index_template = File.read("#{root}/lib/diesel/doc/templates/index.erb")

    ERB.new(index_template, nil, "-%").result(binding)
  end

  def doc_endpoint_request_methods(endpoint)
    upcased_array = endpoint.opts[:request_methods].collect {|method_sym| method_sym.to_s.upcase}
    upcased_array.collect {|method_str| method_str.gsub('"', '')}.join(', ')
  end
end