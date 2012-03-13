module Distil::Doc
  
  def to_md
    index_template = File.read("./template.erb")

    puts ERB.new(index_template, nil, "-%").result(binding)
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

end