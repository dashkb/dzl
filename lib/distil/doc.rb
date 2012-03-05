module Distil::Doc

  def to_md
    index_template = File.read("./template.erb")

    puts ERB.new(index_template, nil, "-%").result(binding)
  end

  private
  def doc_param_type(type)
    "Format: #{type}"
  end
  
  def doc_param_size(size)
    first_condition = size.conditions.shift
    if first_condition
      doc_str = "Size: Must be #{first_condition[0]} #{first_condition[1]}"
      size.conditions.each do |condition|
        doc_str += " and must be #{condition[0]} #{condition[1]}"
      end
      doc_str += "."
    end
  end

  def doc_param_allowed_values(allowed_values)
    "Allowed values: #{allowed_values}"
  end

  # Don't doc transforms
  def doc_param_prevalidate_transform(a);  end

end