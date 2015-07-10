module Sequel
  module SQL
	class Function
		def to_str
			"#{self.name}(#{self.args.first})"
		end
	end
  end
end	

module Sequel
  class Dataset
	PIVOT = ' PIVOT ('.freeze
	FOR = ' FOR '.freeze
	IN = ' IN ('.freeze
	UNPIVOT = ' UNPIVOT ('.freeze
		
	def pivot_sql_append(func,pivot_for,*columns)
		fn = func.is_a?(Sequel::SQL::Function) ? func.to_str: func
		pivot_sql = sql
		pivot_sql << PIVOT
		pivot_sql << fn
		pivot_sql << FOR
		pivot_sql << pivot_for.to_s
		pivot_sql << IN
		expression_list_append(pivot_sql,columns)
		pivot_sql << PAREN_CLOSE
		clone(:sql => pivot_sql)
	end
	
	def unpivot_sql_append(unpivot_for,column,*values)
		literal_values = values.map {|v| Sequel.lit((v.expression.to_s) + ' as ' + (v.aliaz.to_s))}
		unpivot_sql = sql
		unpivot_sql << PAREN_CLOSE
		unpivot_sql << UNPIVOT
		unpivot_sql << unpivot_for.to_s
		unpivot_sql << FOR
		unpivot_sql << column.to_s
		unpivot_sql << IN
		expression_list_append(unpivot_sql,literal_values)
		unpivot_sql << PAREN_CLOSE
		clone(:sql => unpivot_sql)
	end
	
	def pivot(func,pivot_for,*columns)
		dataset = pivot_sql_append(func,pivot_for,*columns)
		dataset.from_self(:alias => :pivot_table)
	end
	
	def unpivot(unpivot_for,column,*values)
		dataset = unpivot_sql_append(unpivot_for,column,*values)
		dataset.from_self(:alias => :unpivot_table)
	end
		
  end
end	
