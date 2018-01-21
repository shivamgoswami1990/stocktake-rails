module HasScopeGenerator
  extend HasScope
  def scope_initialize(controller, model)

    model.column_names.each do |s|
      controller.has_scope ("by_" + s).to_sym
      if (model.columns_hash[s].type.eql?(:date) || model.columns_hash[s].type.eql?(:float))
        controller.has_scope ("by_" + s + "__gt").to_sym
        controller.has_scope ("by_" + s + "__gte").to_sym
        controller.has_scope ("by_" + s + "__lt").to_sym
        controller.has_scope ("by_" + s + "__lte").to_sym
      end

      if model.columns_hash[s].type.eql?(:string) || model.columns_hash[s].type.eql?(:text)
        controller.has_scope ("by_" + s + "__partial").to_sym
      end
    end
  end
end