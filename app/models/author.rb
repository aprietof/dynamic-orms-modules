class Author

  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :state => "TEXT",
    :city => "TEXT",
  }


  include Persistable::InstanceMethods
  extend Persistable::ClassMethods

end
