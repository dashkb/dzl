module Dzl::EndpointDoc

  def to_md
    endpoint_template = File.read("./lib/dzl/doc/templates/endpoint.erb")

    ERB.new(endpoint_template, nil, "-%").result(binding)
  end

  def doc_file_name
    route.titlecase.gsub("/", "")
  end

  def doc_endpoint_request_methods
    upcased_array = opts[:request_methods].collect {|method_sym| method_sym.to_s.upcase}
    upcased_array.collect {|method_str| method_str.gsub('"', '')}.sort.join(', ')
  end

  private
  def doc_list(list)
    # At this point, ranges were converted to arrays, so best guess
    if list.all?{|e| e.class == Fixnum} && list.first < list.last
      "#{list.first}..#{list.last}"
    else
      "#{list}"
    end
  end

  def doc_conditions(conditions)
    first_condition = conditions.shift
    # All arrays have a size validiton, but the conditions are optional
    doc_str = ""
    if first_condition
      doc_str = "Must be #{first_condition[0]} #{first_condition[1]}"
      conditions.each do |condition|
        doc_str += " and must be #{condition[0]} #{condition[1]}"
      end
      doc_str += "."
    end
    return doc_str
  end

  def doc_param_type(type)
    "Format: #{type}"
  end
  
  def doc_param_size(size)
    condition_doc = doc_conditions(size.conditions)
    "Size: #{condition_doc}" unless condition_doc == ""
  end

  def doc_param_allowed_values(allowed_values)
    "Allowed values: #{doc_list(allowed_values)}"
  end

  def doc_param_disallowed_values(disallowed_values)
    "Disallowed values: #{doc_list(disallowed_values)}"
  end

  def doc_param_value(value)
    condition_doc = doc_conditions(value.conditions)
    "Value: #{condition_doc}" unless condition_doc == ""
  end

  # Don't doc transforms
  def doc_param_prevalidate_transform(a);  end

  # Don't doc procs
  def doc_param_procs(a);  end

end