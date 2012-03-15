class Dzl::DSLSubjects::Parameter
  module AllowedValues
    def allowed_values(input)
      unless (@validations[:allowed_values].present? ||
           @validations[:disallowed_values].present?)
        return Dzl::ValueOrError.new(v: input)
      end

      if @validations[:disallowed_values].present?
        valid = true

        if input.is_a?(Array)
          valid = input.none? do |value|
            @validations[:disallowed_values].include?(value)
          end
        elsif input.is_a?(String)
          valid = !@validations[:disallowed_values].include?(input)
        end

        return Dzl::ValueOrError.new(e: :disallowed_values_failed) unless valid
      end

      if @validations[:allowed_values].present?
        valid = true

        if param_type == Array
          valid = input.all? do |value|
            @validations[:allowed_values].include?(value)
          end
        elsif param_type == String
          valid = @validations[:allowed_values].include?(input)
        end

        return Dzl::ValueOrError.new(e: :allowed_values_failed) unless valid
      end

      Dzl::ValueOrError.new(v: input)
    end

    def regex_match(input)
      return Dzl::ValueOrError.new(v: input) unless @validations[:matches].present?
      
      error = nil

      if input.is_a?(String)
        unless @validations[:matches].any? {|re| re.match(input)}
          error = Dzl::ValueOrError.new(e: :regex_match_fail)
        end
      elsif input.is_a?(Array)
        input.each do |v|
          unless @validations[:matches].any? {|re| re.match(v)}
            error = Dzl::ValueOrError.new(e: :regex_match_fail)
          end
        end
      end

      return error ? error : Dzl::ValueOrError.new(v: input)
    end
  end
end