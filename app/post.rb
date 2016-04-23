class Post

  ATRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :title => "TEXT",
    :content => "TEXT"
  }

  ATRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{table_name} (
      id INTEGER PRIMARY KEY,
      title TEXT,
      content TEXT
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

  private
  def insert
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (title, content) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.title, self.content)
    self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
    puts "Object Inserted".green
    self.id
  end

  def update
    sql = <<-SQL
      UPDATE posts SET title = ?, content = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.title, self.content, self.id)
    puts "Object Updated".green
    self.id
  end

end
