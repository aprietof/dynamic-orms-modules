class Author

  ATRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :state => "TEXT",
    :city => "TEXT"
  }

  ATRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_sql
    ATRIBUTES.collect do |attribute_name, schema|
      "#{attribute_name} #{schema}"
    end.join(",")
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{table_name} (
        #{self.create_sql}
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.reify_from_row(row)
    self.new.tap do |p|
      ATRIBUTES.keys.each.with_index do |attribute_name, i|
        p.send("#{attribute_name}=", row[i])
      end
    end
  end

  def self.find(id)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE id == ? LIMIT 1
    SQL

    row = DB[:conn].execute(sql, id).flatten
    self.reify_from_row(row)
  end

  def ==(other)
    self.id == other.id
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    !!self.id
  end

  def self.attribute_names_for_insert
    ATRIBUTES.keys[1..-1].join(",")
  end

  def self.question_marks_for_insert
    ATRIBUTES.keys[1..-1].size.times.collect{"?"}.join(",")
  end

  def self.sql_for_update
    ATRIBUTES.keys[1..-1].collect {|attribute_name| "#{attribute_name} = ?"}.join(",")
  end

  def attribute_values
    ATRIBUTES.keys[1..-1].collect {|attribute_name| self.send(attribute_name)}
  end

  private
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
