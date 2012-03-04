class Diesel::DSLSubjects::Parameter
  module TypeConversion
    def convert_type(input)
      if param_type == String
        Diesel::ValueOrError.new(v: input)
      elsif param_type == Array
        Diesel::ValueOrError.new(
          v: input.split(@opts[:separator])
        )
      elsif param_type == Integer
        if (input = input.to_i.to_s) == input
          Diesel::ValueOrError.new(v: input)
        else
          Diesel::ValueOrError.new(
            e: :type_conversion_error
          )
        end
      elsif param_type == Date || param_type == Time
        input = Time.parse(input) rescue nil
        if input
          input = input.to_date if param_type == Date
          Diesel::ValueOrError.new(v: input)
        else
          Diesel::ValueOrError.new(
            e: :type_conversion_error
          )
        end
      end
    end

    def prevalidate_transform(input)
      if @validations.has_key?(:prevalidate_transform)
        @validations[:prevalidate_transform].each do |transform|
          input = transform.call(input)
        end
      end

      Diesel::ValueOrError.new(v: input)
    end
  end
end