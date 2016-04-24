class Author

  ATRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :state => "TEXT",
    :city => "TEXT"
  }

  def self.attributes
    ATRIBUTES
  end

  ATRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  include Persistable::InstanceMethods
  extend Persistable::ClassMethods


end
