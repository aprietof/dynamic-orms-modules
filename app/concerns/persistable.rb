module Persistable

  module ClassMethods

    def table_name
      "#{self.to_s.downcase}s"
    end

    def create_sql
      self.attributes.collect do |attribute_name, schema|
        "#{attribute_name} #{schema}"
      end.join(",")
    end

    def create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS #{self.table_name} (
          #{self.create_sql}
        )
      SQL

      DB[:conn].execute(sql)
    end

    def reify_from_row(row)
      self.new.tap do |p|
        self.attributes.keys.each.with_index do |attribute_name, i|
          p.send("#{attribute_name}=", row[i])
        end
      end
    end

    def find(id)
      sql = <<-SQL
        SELECT * FROM #{self.table_name} WHERE id == ? LIMIT 1
      SQL

      row = DB[:conn].execute(sql, id).flatten
      if row.first
        self.reify_from_row(row)
      else
        nil
      end
    end

    def attribute_names_for_insert
      self.attributes.keys[1..-1].join(",")
    end

    def question_marks_for_insert
      self.attributes.keys[1..-1].size.times.collect{"?"}.join(",")
    end

    def sql_for_update
      self.attributes.keys[1..-1].collect {|attribute_name| "#{attribute_name} = ?"}.join(",")
    end
  end


  module InstanceMethods

    def ==(other)
      self.id == other.id
    end

    def save
      persisted? ? update : insert
    end

    def persisted?
      !!self.id
    end

    def attribute_values
      self.class.attributes.keys[1..-1].collect {|attribute_name| self.send(attribute_name)}
    end

    def insert
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{self.class.attribute_names_for_insert}) VALUES (#{self.class.question_marks_for_insert})
      SQL

      DB[:conn].execute(sql, *attribute_values)
      self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
      puts "Object Inserted".green
      self.id
    end

    def update
      sql = <<-SQL
        UPDATE #{self.class.table_name} SET #{self.class.sql_for_update} WHERE id = ?
      SQL

      DB[:conn].execute(sql, *attribute_values, self.id)
      puts "Object Updated".green
      self.id
    end
  end

end
