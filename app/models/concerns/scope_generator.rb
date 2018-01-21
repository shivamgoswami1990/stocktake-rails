module ScopeGenerator
  def createScope(model)
    model.column_names.each do |s|
      # Exact string match
      model.scope ("by_" +s).to_sym, -> temp {model.where(s.to_sym => temp) }

      #Partial Match for String and text fields
      if model.columns_hash[s].type.eql?(:string) || model.columns_hash[s].type.eql?(:text)
        model.scope ("by_" +s + "__partial").to_sym, -> temp { model.where("#{s} LIKE ? " , "%#{temp}%") }

      elsif model.columns_hash[s].type.eql?(:date) || model.columns_hash[s].type.eql?(:float)
        model.scope ("by_" +s + "__gt").to_sym, -> temp {model.where("#{s} > ?", temp) }
        model.scope ("by_" +s + "__gte").to_sym, -> temp {model.where("#{s} >= ?", temp) }
        model.scope ("by_" +s + "__lt").to_sym, -> temp {model.where("#{s} < ?", temp) }
        model.scope ("by_" +s + "__lte").to_sym, -> temp {model.where("#{s} <= ?", temp) }
      end
    end
  end
end